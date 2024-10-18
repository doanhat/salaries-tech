import json
import os
import sys

import requests

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from dotenv import load_dotenv
from langchain.agents import Tool
from langchain_community.tools import DuckDuckGoSearchRun
from langchain_core.messages import AIMessage, HumanMessage, SystemMessage
from langchain_openai import ChatOpenAI
from api.models import CompanyDB, CompanyType, TagDB
from openai import OpenAI
from sqlalchemy import create_engine, distinct, func
from sqlalchemy.orm import sessionmaker

# Load environment variables
load_dotenv()

# Set up OpenAI client
client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

# Database setup
SQLALCHEMY_DATABASE_URL = "sqlite:///./salaries.db"
engine = create_engine(
    SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Set up LangChain tools
search = DuckDuckGoSearchRun()
tools = [
    Tool(
        name="DuckDuckGo Search",
        func=search.run,
        description="Useful for searching the web for current information about companies.",
    )
]


def get_distinct_tags():
    db = SessionLocal()
    try:
        distinct_tags = db.query(distinct(TagDB.name)).all()
        return [tag[0] for tag in distinct_tags]
    finally:
        db.close()


def get_company_info(company_name, existing_tags):
    chat = ChatOpenAI(temperature=0, model="gpt-4-1106-preview")

    system_message = SystemMessage(
        content=f"""You are a helpful assistant that provides information about companies.
For the company '{company_name}', provide the following information:
1. Company Type: (choose from: startup, scale-up, sme, large-enterprise, freelance, npo, institution)
2. Tags: (comma-separated list of tags)
Use the following existing tags if applicable: {', '.join(existing_tags[:200])}
If possible, choose tags from the list of existing tags, but feel free to suggest new ones if none fit. You don't need to explain why.
Avoid using 'technology' in the list of tags.
Use the DuckDuckGo Search tool to find up-to-date information about the company.

Provide the answer in the format:
Type: [company type]
Tags: [tag1, tag2, tag3]
"""
    )

    human_message = HumanMessage(
        content=f"Find information about the company {company_name}"
    )

    messages = [system_message, human_message]

    while True:
        ai_message = chat.invoke(messages)

        if ai_message.additional_kwargs.get("function_call"):
            function_call = ai_message.additional_kwargs["function_call"]
            function_name = function_call["name"]
            function_args = json.loads(function_call["arguments"])

            if function_name == "DuckDuckGo Search":
                search_result = search.run(function_args["query"])
                messages.append(
                    AIMessage(
                        content=ai_message.content,
                        additional_kwargs=ai_message.additional_kwargs,
                    )
                )
                messages.append(HumanMessage(content=f"Search result: {search_result}"))
            else:
                raise ValueError(f"Unknown function: {function_name}")
        else:
            return ai_message.content


def update_database(
    current_name, new_name, current_type, new_type, current_tags, new_tags
):
    db = SessionLocal()
    try:
        # Find the company
        company = db.query(CompanyDB).filter(CompanyDB.name == current_name).first()

        if not company:
            # If company doesn't exist, create a new one
            company = CompanyDB(name=new_name, type=new_type)
            db.add(company)
        else:
            # Update existing company
            if new_name != current_name:
                company.name = new_name
            if new_type != current_type:
                company.type = new_type

        # tags to be added
        tags_to_add = [tag for tag in new_tags if tag not in current_tags]
        print(f"Tags to add: {tags_to_add}")
        # tags to be removed
        tags_to_remove = [tag for tag in current_tags if tag not in new_tags]
        print(f"Tags to remove: {tags_to_remove}")
        for tag_name in tags_to_add:
            tag = db.query(TagDB).filter(TagDB.name == tag_name.lower()).first()
            if not tag:
                tag = TagDB(name=tag_name.lower())
                db.add(tag)
            company.tags.append(tag)
        for tag_name in tags_to_remove:
            tag = db.query(TagDB).filter(TagDB.name == tag_name.lower()).first()
            if tag:
                company.tags.remove(tag)

        db.commit()
        print(
            f"Updated company: {company.name}, Type: {company.type}, Tags: {[tag.name for tag in company.tags]}"
        )
    finally:
        db.close()


def get_companies_from_db():
    db = SessionLocal()
    try:
        companies = db.query(CompanyDB.name).order_by(func.lower(CompanyDB.name)).all()
        return [company.name for company in companies if company.name]
    finally:
        db.close()


def process_companies():
    companies = get_companies_from_db()

    for company_name in companies:
        existing_tags = get_distinct_tags()
        print(f"\nProcessing: {company_name}")
        try:
            info = get_company_info(company_name, existing_tags)
            print(f"ChatGPT response:\n{info}")

            # Extract company type and tags from the response
            lines = info.split("\n")
            suggested_type = next(
                (
                    line.split(": ")[1].lower()
                    for line in lines
                    if line.startswith("Type:")
                ),
                None,
            )
            suggested_tags = next(
                (
                    line.split(": ")[1].split(", ")
                    for line in lines
                    if line.startswith("Tags:")
                ),
                [],
            )

            if suggested_type:
                suggested_type = suggested_type.strip().lower()
            suggested_tags = [tag.strip().lower() for tag in suggested_tags]

            print(
                f"ChatGPT Suggestion - Company type: {suggested_type}, Tags: {suggested_tags}"
            )

            # Get current company info from the database
            db = SessionLocal()
            try:
                current_company = (
                    db.query(CompanyDB).filter(CompanyDB.name == company_name).first()
                )
                if current_company:
                    current_name = current_company.name
                    current_type = current_company.type
                    current_tags = [tag.name for tag in current_company.tags]
                    print(
                        f"Current DB info - Name: {current_name}, Type: {current_type}, Tags: {current_tags}"
                    )
                else:
                    print("Company not found in the database.")
                    continue
            finally:
                db.close()

            # Validate company type
            if suggested_type not in [ct.value for ct in CompanyType]:
                print(f"Invalid suggested company type: {suggested_type}")
                suggested_type = None

            while True:
                action = input(
                    "Enter 's' to skip, 'u' to update manually, 'a' to accept ChatGPT suggestions, or 'q' to quit: "
                ).lower()

                if action == "s" or action == "":
                    break
                elif action == "u":
                    new_name = (
                        input(
                            f"Enter new company name, enter to keep current ({current_name}): "
                        ).strip()
                        or current_name
                    )
                    new_type = (
                        input(
                            f"Enter new company type, enter to keep current ({current_type}): "
                        )
                        .strip()
                        .lower()
                        or current_type
                    )
                    new_tags_input = input(
                        f"Enter new company tags, enter to keep current ({', '.join(current_tags)}): "
                    ).strip()
                    new_tags = (
                        [tag.strip().lower() for tag in new_tags_input.split(",")]
                        if new_tags_input
                        else current_tags
                    )
                elif action == "a":
                    new_name = current_name  # Keep the current name
                    new_type = (
                        suggested_type
                        if suggested_type in [ct.value for ct in CompanyType]
                        else current_type
                    )
                    new_tags = suggested_tags
                    print(
                        f"Accepting ChatGPT suggestions - Type: {new_type}, Tags: {', '.join(new_tags)}"
                    )
                elif action == "q":
                    return
                else:
                    print("Invalid input. Please try again.")
                    continue

                if action in ["u", "a"]:
                    if new_type not in [ct.value for ct in CompanyType]:
                        print(f"Invalid company type: {new_type}")
                        continue

                    if (
                        new_name != current_name
                        or new_type != current_type
                        or set(new_tags) != set(current_tags)
                    ):
                        update_database(
                            current_name,
                            new_name,
                            current_type,
                            new_type,
                            current_tags,
                            new_tags,
                        )
                        print("Database updated with modified information.")
                    else:
                        print("No changes made.")
                    break

        except Exception as e:
            print(f"Error processing company '{company_name}': {str(e)}")
            print("Skipping to next company...")
            continue


def search_web(query):
    url = f"https://api.duckduckgo.com/?q={query}&format=json"
    response = requests.get(url)
    data = response.json()

    # Extract and format relevant information from the search results
    results = []
    if "RelatedTopics" in data:
        for topic in data["RelatedTopics"][:5]:  # Limit to top 5 results
            if "Text" in topic:
                results.append(topic["Text"])
    print(results)
    return "\n".join(results) if results else "No relevant information found."


if __name__ == "__main__":
    process_companies()

import React from "react";
import { Navbar, Nav, Container, NavDropdown } from "react-bootstrap";
import { Link } from "react-router-dom";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faGithub } from "@fortawesome/free-brands-svg-icons";
import { useLanguage, translations } from "../../contexts/LanguageContext";

const Header = () => {
  const { language, toggleLanguage } = useLanguage();
  const t = translations[language].header;

  return (
    <Navbar bg="light" expand="lg">
      <Container>
        <Navbar.Brand as={Link} to="/">
          {t.brand}
        </Navbar.Brand>
        <Navbar.Toggle aria-controls="basic-navbar-nav" />
        <Navbar.Collapse id="basic-navbar-nav">
          <Nav className="me-auto">
            <Nav.Link
              href="https://salaires.dev/"
              target="_blank"
              rel="noopener noreferrer"
            >
              {t.inspiredBy}{" "}
              <span style={{ color: "red" }}>https://salaires.dev/</span>
            </Nav.Link>
          </Nav>
          <Nav>
            <NavDropdown title={t.languages.current} id="language-dropdown">
              {Object.entries(t.languages.options).map(([code, name]) => (
                <NavDropdown.Item
                  key={code}
                  onClick={() => toggleLanguage(code)}
                  active={language === code}
                >
                  {name}
                </NavDropdown.Item>
              ))}
            </NavDropdown>
            <Nav.Link
              href="https://github.com/doanhat/salaries-tech"
              target="_blank"
              rel="noopener noreferrer"
            >
              <FontAwesomeIcon icon={faGithub} /> {t.github}
            </Nav.Link>
          </Nav>
        </Navbar.Collapse>
      </Container>
    </Navbar>
  );
};

export default Header;

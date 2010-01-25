-- 
-- meetmap postgresql schema
--

CREATE ROLE www LOGIN ENCRYPTED PASSWORD 'password';

CREATE OR REPLACE FUNCTION onupdate_changed() RETURNS trigger AS $$
  BEGIN
    NEW.changed := (current_timestamp at time zone 'UTC');
    RETURN NEW;
  END;
$$ LANGUAGE plpgsql;

CREATE TABLE users (
	id serial NOT NULL,
	username varchar NOT NULL,
	password varchar,
    enabled boolean NOT NULL DEFAULT TRUE,
	email varchar,
	web_url varchar,
    added timestamp(0) without time zone NOT NULL DEFAULT (current_timestamp at time zone 'utc'),
    changed timestamp(0) without time zone NOT NULL DEFAULT (current_timestamp at time zone 'utc'),
    deleted timestamp(0) without time zone,
    PRIMARY KEY (id)
);
GRANT SELECT,UPDATE ON users TO www;
CREATE UNIQUE INDEX username ON users(username);
CREATE TRIGGER users_update BEFORE UPDATE ON users FOR EACH ROW EXECUTE PROCEDURE onupdate_changed();

CREATE TABLE meetings (
	id serial NOT NULL,
	meeter integer NOT NULL REFERENCES users(id),
	meetee integer NOT NULL REFERENCES users(id),
	meeting_date date,
	comments varchar,
	active boolean NOT NULL DEFAULT FALSE,
    added timestamp(0) without time zone NOT NULL DEFAULT (current_timestamp at time zone 'utc'),
    changed timestamp(0) without time zone NOT NULL DEFAULT (current_timestamp at time zone 'utc'),
    deleted timestamp(0) without time zone,
    PRIMARY KEY (id)
);
GRANT INSERT,UPDATE ON meetings TO www;
CREATE TRIGGER meetings_update BEFORE UPDATE ON meetings FOR EACH ROW EXECUTE PROCEDURE onupdate_changed();

CREATE VIEW meetings_expanded AS
  SELECT
    m.*,
	er.username AS meeter_username,
	ee.username AS meetee_username,
	COALESCE((SELECT TRUE FROM meetings m2 WHERE m2.meeter = m.meetee AND m2.meetee = m.meeter AND m2.deleted IS NULL AND m2.active IS TRUE),FALSE) AS reciprocal
  FROM meetings m
  LEFT JOIN users er ON er.id = m.meeter
  LEFT JOIN users ee ON ee.id = m.meetee
  WHERE m.deleted IS NULL AND m.active IS TRUE
    AND er.deleted IS NULL AND er.enabled IS TRUE
    AND ee.deleted IS NULL AND ee.enabled IS TRUE;
   


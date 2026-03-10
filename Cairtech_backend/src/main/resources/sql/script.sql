
CREATE TABLE user_entity (
    id_user UUID NOT NULL DEFAULT gen_random_uuid (),
    email varchar(255) UNIQUE,
    "password" varchar(255),
    phone_number varchar(50),
    last_connection_date TIMESTAMP,
    "active" BOOLEAN,
    "status" varchar(50),
    PRIMARY KEY (id_user)
);


CREATE TABLE bible_club (
    id_bible_club UUID NOT NULL DEFAULT gen_random_uuid (),
    "name" varchar(255),
    "code" varchar(255) UNIQUE,
    localisation varchar(255),
    city varchar(255),
    school_name varchar(255),
    date_creation varchar(50),
    school_level varchar(100),
    capacity_max integer,
    status varchar(50),
    PRIMARY KEY (id_bible_club)
);


CREATE TABLE member_entity (
    id_user UUID NOT NULL,
    first_name varchar(255),
    last_name varchar(255),
    date_of_birth VARCHAR(50),
    gender VARCHAR(10),
    "address" VARCHAR(255),
    "quarter" VARCHAR(255),
    inscription_date VARCHAR(255),
    "status" varchar(50),
    "level" varchar(15),
    sector varchar(50),
    id_bbc uuid,
    PRIMARY KEY (id_user),
    FOREIGN KEY (id_user) REFERENCES user_entity (id_user),
    FOREIGN KEY (id_bbc) REFERENCES bible_club (id_bible_club)
);


CREATE TABLE incharge (
    id_user UUID NOT NULL,
    "function" varchar(255),
    mandate varchar(255),
    nomination_date TIMESTAMP,
    competences TEXT,
    PRIMARY KEY (id_user),
    FOREIGN KEY (id_user) REFERENCES user_entity (id_user)
);


CREATE TABLE role_entity (
    id_role UUID NOT NULL DEFAULT gen_random_uuid (),
    "name" varchar(255),
    "description" varchar(255),
    PRIMARY KEY (id_role)
);


CREATE TABLE user_role_entity (
    id_user UUID,
    id_role UUID,
    FOREIGN KEY (id_user) REFERENCES user_entity (id_user),
    FOREIGN KEY (id_role) REFERENCES role_entity (id_role),
    PRIMARY KEY (id_user, id_role)
);


CREATE TABLE permission_entity (
    id UUID NOT NULL DEFAULT gen_random_uuid (),
    id_role UUID,
    "action" varchar(255),
    ressource varchar(255),
    "description" varchar(255),
    FOREIGN KEY (id_role) REFERENCES role_entity (id_role),
    PRIMARY KEY (id)
);


-- ========================================
-- New tables for extended features
-- ========================================

CREATE TABLE activity_report (
    id UUID NOT NULL DEFAULT gen_random_uuid (),
    "type" varchar(255),
    title varchar(255),
    author varchar(255),
    "status" varchar(50),
    reference varchar(255),
    report_date TIMESTAMP,
    validation_date TIMESTAMP,
    "content" TEXT,
    attachments TEXT,
    validate_by varchar(255),
    PRIMARY KEY (id)
);


CREATE TABLE activity_type (
    id UUID NOT NULL DEFAULT gen_random_uuid (),
    "name" varchar(255),
    "description" varchar(255),
    category varchar(255),
    obligated BOOLEAN,
    frequency INTEGER,
    PRIMARY KEY (id)
);


CREATE TABLE publication (
    id UUID NOT NULL DEFAULT gen_random_uuid (),
    reference varchar(255),
    "type" varchar(255),
    "date" TIMESTAMP,
    title varchar(255),
    "content" TEXT,
    author varchar(255),
    "status" varchar(50),
    validation_date TIMESTAMP,
    recipient varchar(255),
    category varchar(255),
    PRIMARY KEY (id)
);


CREATE TABLE daily_verse (
    id UUID NOT NULL DEFAULT gen_random_uuid (),
    "date" TIMESTAMP,
    reference varchar(255),
    verse TEXT,
    "version" varchar(100),
    "comment" TEXT,
    author varchar(255),
    PRIMARY KEY (id)
);


CREATE TABLE dashboard (
    id UUID NOT NULL DEFAULT gen_random_uuid (),
    "date" TIMESTAMP,
    period varchar(255),
    indicators TEXT,
    PRIMARY KEY (id)
);


CREATE TABLE notification (
    id UUID NOT NULL DEFAULT gen_random_uuid (),
    "type" varchar(100),
    message TEXT,
    recipient varchar(255),
    priority varchar(50),
    viewed BOOLEAN DEFAULT false,
    channel varchar(100),
    created_at TIMESTAMP DEFAULT NOW(),
    PRIMARY KEY (id)
);


CREATE TABLE club_statistics (
    id UUID NOT NULL DEFAULT gen_random_uuid (),
    id_bible_club UUID,
    member_number INTEGER,
    active_member_number INTEGER,
    unactive_member_number INTEGER,
    FOREIGN KEY (id_bible_club) REFERENCES bible_club (id_bible_club),
    PRIMARY KEY (id)
);


CREATE TABLE school_year (
    id UUID NOT NULL DEFAULT gen_random_uuid (),
    label varchar(255),
    starting_date varchar(50),
    ending_date varchar(50),
    is_current BOOLEAN DEFAULT false,
    "status" varchar(50),
    PRIMARY KEY (id)
);


CREATE TABLE personnal_plan (
    id UUID NOT NULL DEFAULT gen_random_uuid (),
    id_user UUID,
    period INTEGER,
    auto_examination TEXT,
    "type" varchar(255),
    "content" TEXT,
    realisations TEXT,
    difficulties TEXT,
    FOREIGN KEY (id_user) REFERENCES user_entity (id_user),
    PRIMARY KEY (id)
);


CREATE TABLE personnal_account (
    id UUID NOT NULL DEFAULT gen_random_uuid (),
    id_user UUID,
    number_presence INTEGER DEFAULT 0,
    number_absences INTEGER DEFAULT 0,
    number_justified_absences INTEGER DEFAULT 0,
    number_consecutive_absences INTEGER DEFAULT 0,
    engagement_score DOUBLE PRECISION DEFAULT 0,
    attendance_rate DOUBLE PRECISION DEFAULT 0,
    abse_rate DOUBLE PRECISION DEFAULT 0,
    last_presence TIMESTAMP,
    "status" varchar(50),
    FOREIGN KEY (id_user) REFERENCES user_entity (id_user),
    PRIMARY KEY (id)
);


CREATE TABLE loyalty_statistics (
    id UUID NOT NULL DEFAULT gen_random_uuid (),
    id_user UUID,
    number_presence INTEGER DEFAULT 0,
    number_absences INTEGER DEFAULT 0,
    number_justified_absences INTEGER DEFAULT 0,
    number_consecutive_absences INTEGER DEFAULT 0,
    engagement_score DOUBLE PRECISION DEFAULT 0,
    attendance_rate DOUBLE PRECISION DEFAULT 0,
    abse_rate DOUBLE PRECISION DEFAULT 0,
    last_presence TIMESTAMP,
    "status" varchar(50),
    FOREIGN KEY (id_user) REFERENCES user_entity (id_user),
    PRIMARY KEY (id)
);
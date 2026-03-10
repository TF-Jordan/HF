
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
    "action" varchar(255),
    "resource" varchar(255),
    FOREIGN KEY (id) REFERENCES role_entity (id_role),
    PRIMARY KEY (id)
);
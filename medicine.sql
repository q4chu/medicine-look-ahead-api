DROP TABLE IF EXISTS `BC_drug_formulary`;

//dump bc drug formulary into database, since DIN_PIN is not unique, it is not primary key

CREATE TABLE `BC_drug_formulary` (
    id INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
    DIN_PIN INT UNSIGNED NOT NULL,
    Rec_Eff_Date DECIMAL(8),
    Rec_End_Date DECIMAL(8),
    Brand_Nm VARCHAR(100),
    Generic_Nm VARCHAR(100) DEFAULT NULL,
    Dosage_Form VARCHAR(20) DEFAULT NULL,
    Max_Price DECIMAL(8,4),
    LCA_Price DECIMAL(8,4),
    Pcare_Plan_Desc VARCHAR(100) DEFAULT NULL,
    Max_Days_Supply INT(10) UNSIGNED,
    Formulary_List_Date DECIMAL(8),
    PRIMARY KEY (`id`)
) ENGINE=InnoDB;

LOAD DATA INFILE '/var/lib/mysql-files/modified_bc_formulary.csv' INTO TABLE BC_drug_formulary
FIELDS TERMINATED BY ',' OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 LINES
(BC_drug_formulary.DIN_PIN,BC_drug_formulary.Rec_Eff_Date,BC_drug_formulary.Rec_End_Date,BC_drug_formulary.Brand_Nm,BC_drug_formulary.Generic_Nm,BC_drug_formulary.Dosage_Form,
    BC_drug_formulary.Max_Price,BC_drug_formulary.LCA_Price,BC_drug_formulary.Pcare_Plan_Desc,BC_drug_formulary.Max_Days_Supply,BC_drug_formulary.Formulary_List_Date);


//dump mp dataset into database, mp is the formal name of drug with company name

DROP TABLE IF EXISTS `mp_full_release`;

CREATE TABLE `mp_full_release` (
    mp_code INT(10) UNSIGNED NOT NULL,
    mp_formal_name VARCHAR(300) NOT NULL,
    mp_status ENUM('active','inactive'),
    mp_status_effective_time DECIMAL(8) DEFAULT NULL,
    PRIMARY KEY (`mp_code`)
) ENGINE=InnoDB;

LOAD DATA INFILE '/var/lib/mysql-files/mp_full_release.csv' INTO TABLE mp_full_release
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(mp_code,mp_formal_name,@discard1,@discard2,mp_status,mp_status_effective_time);


//dump relationship dataset into database, it is a table to link mp,ntp,tm together

DROP TABLE IF EXISTS `mp_ntp_tm_relationship`;

CREATE TABLE `mp_ntp_tm_relationship` (
    mp_code INT UNSIGNED NOT NULL,
    ntp_code INT UNSIGNED NOT NULL,
    tm_code INT UNSIGNED NOT NULL
) ENGINE=InnoDB;

LOAD DATA INFILE '/var/lib/mysql-files/mp_ntp_tm_relationship.csv' INTO TABLE mp_ntp_tm_relationship
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(mp_code,@mpformal,ntp_code,@ntpformal,tm_code,@tmformal);


//dump mp, din relationship dataset into database, it is a table to map din to mp and vice versa

DROP TABLE IF EXISTS `mp_to_din_or_npn_mapping`;

CREATE TABLE `mp_to_din_or_npn_mapping` (
    mp_code INT UNSIGNED,
    health_canada_identifier INT UNSIGNED NOT NULL,
    health_canada_product_name VARCHAR(100),
    health_canada_description VARCHAR(100),
    PRIMARY KEY(`mp_code`)
) ENGINE=InnoDB;

LOAD DATA INFILE '/var/lib/mysql-files/mp_to_din_or_npn_mapping.csv' INTO TABLE mp_to_din_or_npn_mapping
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES  TERMINATED BY '\r\n'
IGNORE 1 LINES
(mp_code,@formal_name, health_canada_identifier, health_canada_product_name, health_canada_description);


//dump mp dataset into database, ntp is the formal name of drug

DROP TABLE IF EXISTS `ntp_full_release`;

CREATE TABLE `ntp_full_release` (
    ntp_code INT UNSIGNED NOT NULL,
    ntp_formal_name VARCHAR(300) NOT NULL,
    ntp_status ENUM('active','inactive'),
    npt_status_effective_time DECIMAL(8),
    npt_type VARCHAR(10),
    PRIMARY KEY(`ntp_code`)
) ENGINE=InnoDB;

LOAD DATA INFILE '/var/lib/mysql-files/ntp_full_release.csv' INTO TABLE ntp_full_release
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES
(ntp_code,ntp_formal_name,@en,@fr,ntp_status,npt_status_effective_time,npt_type);

//dump mp dataset into database, tm is the category of drug

DROP TABLE IF EXISTS `tm_full_release`;

CREATE TABLE `tm_full_release` (
    tm_code INT UNSIGNED NOT NULL,
    tm_formal_name VARCHAR(100) NOT NULL,
    tm_status ENUM('active','inactive'),
    tm_status_effective_time DECIMAL(8),
    PRIMARY KEY(`tm_code`)
) ENGINE=InnoDB;

LOAD DATA INFILE '/var/lib/mysql-files/tm_full_release.csv' INTO TABLE tm_full_release
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 LINES;


CREATE TABLE `ccdds` AS
SELECT tm.*,ntp.*,mp.*, mapping.health_canada_identifier, mapping.health_canada_description, mapping.health_canada_product_name
FROM tm_full_release tm, ntp_full_release ntp, mp_to_din_or_npn_mapping mapping, mp_ntp_tm_relationship relationship, mp_full_release mp
WHERE tm.tm_code = relationship.tm_code and ntp.ntp_code = relationship.ntp_code and mp.mp_code = relationship.mp_code and mp.mp_code = mapping.mp_code;

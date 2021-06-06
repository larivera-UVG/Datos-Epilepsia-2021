create database if not exists humana;

use humana;

create table if not exists pacientes(
	id_paciente int not null,
	sexo varchar(1) not null,
	fecha_nacimiento date not null,
	antecedentes text,
	diagnostico text,
	condicion varchar(10) not null,
	primary key (id_paciente)
);

create table if not exists pruebas(
	id_prueba int not null auto_increment,
	id_paciente int not null,
	fecha_prueba date not null,
	hora_inicio time not null,
	duracion int not null,
	frecuencia int not null,
	no_canales int not null,
	prueba longblob not null,
	primary key (id_prueba, id_paciente),
	constraint fk_pruebas foreign key (id_paciente) references pacientes(id_paciente)
);

create table if not exists pruebas_datos(
	id int not null auto_increment,
	id_prueba int not null,
	canal_1 float(8,3) not null,
	canal_2 float(8,3) not null,
	canal_3 float(8,3) not null,
	canal_4 float(8,3) not null,
	canal_5 float(8,3) not null,
	canal_6 float(8,3) not null,
	canal_7 float(8,3) not null,
	canal_8 float(8,3) not null,
	canal_9 float(8,3) not null,
	canal_10 float(8,3) not null,
	canal_11 float(8,3) not null,
	canal_12 float(8,3) not null,
	canal_13 float(8,3) not null,
	canal_14 float(8,3) not null,
	canal_15 float(8,3) not null,
	canal_16 float(8,3) not null,
	canal_17 float(8,3) not null,
	canal_18 float(8,3) not null,
	canal_19 float(8,3) not null,
	canal_20 float(8,3) not null,
	canal_21 float(8,3),
	canal_22 float(8,3),
	canal_23 float(8,3),
	canal_24 float(8,3),
	canal_25 float(8,3),
	canal_26 float(8,3),
	canal_27 float(8,3),
	canal_28 float(8,3),
	canal_29 float(8,3),
	canal_30 float(8,3),
	canal_31 float(8,3),
	canal_32 float(8,3),
	canal_33 float(8,3),
	canal_34 float(8,3),
	canal_35 float(8,3),
	primary key (id),
	constraint fk_pdatos foreign key (id_prueba) references pruebas(id_prueba)
);

#drop database if exists humana;
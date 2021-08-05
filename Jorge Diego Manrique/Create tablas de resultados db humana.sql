use humana;

drop table resultados_analisis;
drop table analisis;
drop table paciente_datos_personales;

create table if not exists analisis(
	id_analisis int not null auto_increment,
	fecha_analisis date not null,
	realizado_por varchar(50) not null,
	modelo_utilizado varchar(20) not null,
	descripcion varchar(50),
	notas varchar(50),
	id_prueba int not null,
	primary key (id_analisis),
	constraint fk_prueba foreign key (id_prueba) references pruebas(id_prueba)
);

create table if not exists resultados_analisis(
	id int not null auto_increment,
	id_analisis int not null,
	mav float,
	zc int,
	type1_error int,
	type2_error int,
	Specificity float, #true negatives rate
	AUC float,
	AUC_Class varchar(10),
	MSE float,
	RMSE float,
	MAE float,
	R2 float,
	primary key (id),
	constraint fk_analisis foreign key (id_analisis) references analisis(id_analisis)
);

create table if not exists paciente_datos_personales(
	id int not null auto_increment,
	id_paciente int not null,
	primer_nombre varchar(10),
	segundo_nombre varchar(10),
	primer_apellido varchar(10),
	segundo_apellido varchar(10),
	apellido_casada varchar(10),
	notas_importantes varchar(50),
	primary key (id),
	constraint fk_paciente_datos foreign key (id_paciente) references pacientes(id_paciente)
);

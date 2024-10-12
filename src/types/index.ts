export interface ReportDetailData {
  cedula: number;
  nombre: string;
  depnombre: string;
  salariobruto: number;
  fechapago: string;
  pateym: string;
  pativm: string;
  obreym: string;
  obrivm: string;
  obrbanco: string;
  obrsolidarista: string;
  impuestorenta: string;
  resaguinaldo: string;
  rescesantia: string;
  resvacaciones: string;
}

export interface ReportTotalData {
  salariobruto: number;
  pateym: string;
  pativm: string;
  obreym: string;
  obrivm: string;
  obrbanco: string;
  obrsolidarista: string;
  impuestorenta: string;
  resaguinaldo: string;
  rescesantia: string;
  resvacaciones: string;
}

export interface DepartmentTotalData {
  depnombre: string;
  salariobruto: number;
  pateym: string;
  pativm: string;
  obreym: string;
  obrivm: string;
  obrbanco: string;
  obrsolidarista: string;
  impuestorenta: string;
  resaguinaldo: string;
  rescesantia: string;
  resvacaciones: string;
}

export interface DepartmentEmployeeData {
  depnombre: string;
  cedula: number;
  nombre: string;
  salariobruto: number;
  hijos: number;
  conyuge: boolean;
  obrsolidarista: string;
  validfrom: Date;
}

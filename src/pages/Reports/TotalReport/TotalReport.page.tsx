// React
import { useEffect, useState } from 'react';
// API
import { getDepartments, getReportTotal } from '@api';
// Components
import {
  CheckboxCard,
  DateRangePicker,
  SearchableSelect,
  SearchInput,
  TotalReportTable,
} from '@components';
// Types
import { ReportTotalData } from '@types';
// Mantine
import { Title } from '@mantine/core';
// Classes
import classes from '../DetailedReport.page.module.css';

export function TotalReportPage() {
  const [totalData, setTotalData] = useState<ReportTotalData[]>([]);
  const [departments, setDepartments] = useState<{ label: string; value: number }[]>([]);
  const [selectedDepartment, setSelectedDepartment] = useState<{
    label: string;
    value: number;
  } | null>(null);
  const [showPatronal, setShowPatronal] = useState(true);
  const [showObrero, setShowObrero] = useState(true);
  const [showReservas, setShowReservas] = useState(true);
  const [IDCard, setIDCard] = useState('');
  const [dateRange, setDateRange] = useState<[Date | null, Date | null]>([null, null]);

  useEffect(() => {
    getDepartments().then((departmentsData) => {
      const formattedDepartments = departmentsData.map((dep: any) => ({
        label: dep.depnombre,
        value: dep.departamentoid,
      }));
      setDepartments(formattedDepartments);
    });
  }, []);

  const loadPageData = () => {
    setTotalData([]);

    const params: any = {};

    if (selectedDepartment) {
      params.departmentID = selectedDepartment.value.toString();
    }

    if (IDCard) {
      params.IDCard = IDCard;
    }

    if (dateRange[0]) {
      params.startDate = dateRange[0].toISOString();
    }

    if (dateRange[1]) {
      params.endDate = dateRange[1].toISOString();
    }

    getReportTotal(params)
      .then((responseData) => {
        setTotalData(responseData);
      })
      .catch((error) => {
        console.error('Error fetching report totals:', error);
      });
  };

  useEffect(() => {
    loadPageData();
  }, [selectedDepartment, IDCard, dateRange]);

  return (
    <div className={classes.mainLayout}>
      <header className={classes.header}>
        <Title>Reporte de Totales</Title>
        <div className={classes.checkboxCardContainer}>
          <CheckboxCard
            label="Deducciones Patronales"
            description="Mostrar/ocultar columnas de deducciones patronales"
            checked={showPatronal}
            onChange={setShowPatronal}
          />
          <CheckboxCard
            label="Deducciones Obrero"
            description="Mostrar/ocultar columnas de deducciones obrero"
            checked={showObrero}
            onChange={setShowObrero}
          />
          <CheckboxCard
            label="Reservas"
            description="Mostrar/ocultar columnas de reservas"
            checked={showReservas}
            onChange={setShowReservas}
          />
        </div>
        <div className={classes.inputsContainer}>
          <SearchInput
            type="number"
            value={IDCard}
            onChange={setIDCard}
            placeholder="Búsqueda por cédula"
            label="Cédula"
          />
          <SearchableSelect
            items={departments}
            selectedItem={selectedDepartment}
            setSelectedItem={setSelectedDepartment}
            placeholder="Seleccione un departamento"
            label="Departamento"
          />
        </div>
        <DateRangePicker
          startDateLabel="Fecha de inicio"
          endDateLabel="Fecha de fin"
          startDatePlaceholder="Seleccione una fecha"
          endDatePlaceholder="Seleccione una fecha"
          placeholder="Seleccione un rango"
          initialRange={dateRange}
          onRangeChange={setDateRange}
        />
      </header>
      <main className={classes.main}>
        <Title order={2}>Resumen</Title>
        <TotalReportTable
          data={totalData}
          showPatronal={showPatronal}
          showObrero={showObrero}
          showReservas={showReservas}
        />
      </main>
    </div>
  );
}

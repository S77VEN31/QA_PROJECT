import { useEffect, useRef, useState } from 'react';
// API
import { getDepartments, getReportDetail } from '@api';
// Components
import {
  CheckboxCard,
  DateRangePicker,
  ElipticPagination,
  FortnightReportTable,
  SearchableSelect,
  SearchInput,
} from '@components';
// Types
import { ReportDetailData } from '@types';
// Mantine
import { Loader, Text, Title } from '@mantine/core';
// Classes
import classes from '../DetailedReport.page.module.css';

export function DetailedReportPage() {
  const [data, setData] = useState<ReportDetailData[]>([]);
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
  const [activePage, setActivePage] = useState(1);
  const [loading, setLoading] = useState(false);
  const tableRef = useRef<HTMLDivElement>(null);
  const limitRange = 9;

  useEffect(() => {
    getDepartments().then((departmentsData) => {
      const formattedDepartments = departmentsData.map((dep: any) => ({
        label: dep.depnombre,
        value: dep.departamentoid,
      }));
      setDepartments(formattedDepartments);
    });
  }, []);

  const loadPageData = (page: number) => {
    setLoading(true);
    setActivePage(page);
    setData([]);

    const params: any = {
      startRange: (page - 1) * limitRange,
      limitRange,
    };

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

    getReportDetail(params)
      .then((responseData) => {
        setData(responseData);
        console.log('Report details:', responseData);
      })
      .catch((error) => {
        console.error('Error fetching report details:', error);
      })
      .finally(() => {
        setLoading(false);
      });
  };

  const focusTable = () => {
    if (tableRef.current) {
      tableRef.current.focus();
    }
  };

  useEffect(() => {
    loadPageData(1);
    if (selectedDepartment || IDCard || dateRange[0] || dateRange[1]) {
      focusTable();
    }
  }, [selectedDepartment, IDCard, dateRange]);

  const handlePageChange = (page: number) => {
    loadPageData(page);
    focusTable();
  };

  return (
    <div className={classes.mainLayout}>
      <header className={classes.header}>
        <Title>Reporte Detallado</Title>
        <Text>
          Consulte los pagos detallados por quincena. Puede filtrar por cédula, departamento o rango
          de fechas.
        </Text>
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
      <main className={classes.main} ref={tableRef} tabIndex={-1}>
        <Title order={2}>Tabla de reportes detallados</Title>
        {loading ? (
          <div className={classes.loaderContainer}>
            <Loader color="blue" />
          </div>
        ) : (
          <FortnightReportTable
            data={data}
            showPatronal={showPatronal}
            showObrero={showObrero}
            showReservas={showReservas}
          />
        )}
      </main>
      <footer className={classes.footer}>
        <ElipticPagination
          totalPages={activePage + 1}
          activePage={activePage}
          onPageChange={handlePageChange}
        />
      </footer>
    </div>
  );
}

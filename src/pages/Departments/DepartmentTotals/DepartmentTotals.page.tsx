import { useRef, useState } from 'react';
// API
import { getDepartmentTotals } from '@api';
// Components
import {
  CheckboxCard,
  DateRangePicker,
  DepartmentTotalTable,
  ElipticPagination,
} from '@components';
// Types
import { DepartmentTotalData } from '@types';
// Mantine
import { Button, Loader, Text, Title } from '@mantine/core';
// Classes
import classes from './DepartmentTotals.page.module.css';

export function DepartmentTotalsPage() {
  const [data, setData] = useState<DepartmentTotalData[]>([]);
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
  const [searched, setSearched] = useState(false);
  const tableRef = useRef<HTMLDivElement>(null);
  const limitRange = 9;

  const loadPageData = (page: number) => {
    setLoading(true);
    setActivePage(page);
    setData([]);
    setSearched(true); // Marcar que se ha realizado una búsqueda

    const params: any = {
      startRange: (page - 1) * limitRange,
      limitRange,
    };

    if (dateRange[0]) {
      params.startDate = dateRange[0].toISOString();
    }

    if (dateRange[1]) {
      params.endDate = dateRange[1].toISOString();
    }

    getDepartmentTotals(params)
      .then((responseData) => {
        setData(responseData);
        focusTable();
        console.log('Department totals:', responseData);
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

  const handlePageChange = (page: number) => {
    loadPageData(page);
  };

  return (
    <div className={classes.mainLayout}>
      <header className={classes.header}>
        <Title>Totales por departamento</Title>
        <Text>
          Consulte los totales pagados en salarios, deducciones y reservas para todos los
          departamentos.
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
        <div className={classes.searchContainer}>
          <div className={classes.filterContainer}>
            <DateRangePicker
              startDateLabel="Fecha de inicio"
              endDateLabel="Fecha de fin"
              startDatePlaceholder="Seleccione una fecha"
              endDatePlaceholder="Seleccione una fecha"
              placeholder="Seleccione un rango"
              initialRange={dateRange}
              onRangeChange={setDateRange}
            />
          </div>
          <Button onClick={() => loadPageData(1)} className={classes.searchButton} color="blue">
            Buscar
          </Button>
        </div>
      </header>
      <main className={classes.main} ref={tableRef} tabIndex={-1}>
        <Title order={2}>Tabla de reportes totales</Title>
        {loading ? (
          <div className={classes.loaderContainer}>
            <Loader color="blue" />
          </div>
        ) : (
          <>
            {!searched ? (
              <Text>Por favor realice una búsqueda para ver los resultados.</Text>
            ) : data.length > 0 ? (
              <DepartmentTotalTable
                data={data}
                showPatronal={showPatronal}
                showObrero={showObrero}
                showReservas={showReservas}
              />
            ) : (
              <Text>No se encontraron resultados para su búsqueda.</Text>
            )}
          </>
        )}
      </main>
      <footer className={classes.footer}>
        {!loading && searched && (
          <ElipticPagination
            totalPages={activePage + 1}
            activePage={activePage}
            onPageChange={handlePageChange}
          />
        )}
      </footer>
    </div>
  );
}

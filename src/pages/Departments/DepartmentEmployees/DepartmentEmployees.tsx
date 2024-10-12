import { useEffect, useState } from 'react';
// API
import { getDepartmentEmployees, getDepartments } from '@api';
// Components
import {
  CheckboxCard,
  DepartmentEmployeesTable,
  ElipticPagination,
  SearchableSelect,
  SearchInput,
} from '@components';
// Types
import { DepartmentEmployeeData } from '@types';
// Mantine
import { Loader, Text, Title } from '@mantine/core';
// Classes
import classes from './DepartmentEmployees.page.module.css';

export function DepartmentEmployeesPage() {
  const [data, setData] = useState<DepartmentEmployeeData[]>([]);
  const [departments, setDepartments] = useState<{ label: string; value: number }[]>([]);
  const [selectedDepartment, setSelectedDepartment] = useState<{
    label: string;
    value: number;
  } | null>(null);
  const [IDCard, setIDCard] = useState('');
  const [activePage, setActivePage] = useState(1);
  const [loading, setLoading] = useState(false);
  const limitRange = 15;

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

    getDepartmentEmployees(params)
      .then((responseData) => {
        setData(responseData);
        console.log('Department employees:', responseData);
      })
      .catch((error) => {
        console.error('Error fetching Department employees:', error);
      })
      .finally(() => {
        setLoading(false);
      });
  };

  useEffect(() => {
    loadPageData(1);
  }, [selectedDepartment, IDCard]);

  const handlePageChange = (page: number) => {
    loadPageData(page);
  };

  return (
    <div className={classes.mainLayout}>
      <header className={classes.header}>
        <Title>Lista de colaboradores por departamento</Title>
        <Text>
          Consulte los empleados en un departamento y su información de créditos fiscales.
        </Text>
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
      </header>
      <main className={classes.main}>
        <Title order={2}>Tabla de colaboradores</Title>
        {loading ? (
          <div className={classes.loaderContainer}>
            <Loader color="blue" />
          </div>
        ) : (
          <DepartmentEmployeesTable data={data} />
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

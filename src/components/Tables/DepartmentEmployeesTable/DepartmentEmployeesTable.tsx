// React
import { useContext, useState } from 'react';
// Types
import { DepartmentEmployeeData } from '@types';
// Tools
import cx from 'clsx';
import { Link } from 'react-router-dom';
// Mantine
import { ScrollArea, Table, TableCaption } from '@mantine/core';
// Contexts
import { FocusContext } from '@/contexts';
// Classes
import classes from './DepartmentEmployeesTable.module.css';

// Interfaces
interface DepartmentEmployeesTableProps {
  data: DepartmentEmployeeData[];
}

export function DepartmentEmployeesTable({ data }: DepartmentEmployeesTableProps) {
  const [scrolled, setScrolled] = useState(false);

  const focusContext = useContext(FocusContext);

  const rows = data.map((row) => {
    const departmentName = row.depnombre;
    const cedula = row.cedula;
    const nombre = row.nombre;
    const salarioBruto = row.salariobruto;
    const childrenQuantity = row.hijos;
    const spouse = row.conyuge;
    const contributionPercentage = parseFloat(row.obrsolidarista);
    const validFrom = row.validfrom;

    return (
      <Table.Tr key={row.cedula}>
        <Table.Th scope="row">{departmentName}</Table.Th>
        <Table.Td>
          <Link
            to={`/dashboard/collaborators/assign-salary?cardID=${cedula}`}
            style={{ fontSize: 'small' }}
            aria-label={`Ver datos de ${nombre}`}
            onClick={focusContext?.focusContent}
          >
            {cedula}
          </Link>
        </Table.Td>
        <Table.Th scope="row">{nombre}</Table.Th>
        <Table.Td>
          {salarioBruto.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' })}
        </Table.Td>
        <Table.Td>{childrenQuantity}</Table.Td>
        <Table.Td>{spouse ? 'Sí' : 'No'}</Table.Td>
        <Table.Td>{contributionPercentage.toFixed(2)}</Table.Td>
        <Table.Td>{new Date(validFrom).toLocaleDateString()}</Table.Td>
      </Table.Tr>
    );
  });

  return (
    <ScrollArea
      onScrollPositionChange={({ y }) => setScrolled(y !== 0)}
      className={classes.scrollArea}
    >
      <Table miw={800} className={classes.table}>
        <Table.Caption>Tabla de los colaboradores en el departamento</Table.Caption>
        <Table.Thead className={cx(classes.header, { [classes.scrolled]: scrolled })}>
          <Table.Tr>
            <Table.Th>Departamento</Table.Th>
            <Table.Th>Cédula</Table.Th>
            <Table.Th>Nombre</Table.Th>
            <Table.Th>Salario Bruto</Table.Th>
            <Table.Th>Cantidad de hijos</Table.Th>
            <Table.Th>¿Cónyuge?</Table.Th>
            <Table.Th>Porcentaje de contribución a Aso. Solidarista</Table.Th>
            <Table.Th>Fecha de ingreso</Table.Th>
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>{rows}</Table.Tbody>
      </Table>
    </ScrollArea>
  );
}

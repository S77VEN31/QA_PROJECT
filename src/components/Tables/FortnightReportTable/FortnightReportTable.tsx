// React
import { useState } from 'react';
// Types
import { ReportDetailData } from '@types';
// Tools
import cx from 'clsx';
// Mantine
import { Anchor, Group, Progress, ScrollArea, Table, Text } from '@mantine/core';
// Classes
import classes from './FortnightReportTable.module.css';

// Interfaces
interface FortnightReportTableProps {
  data: ReportDetailData[];
  showPatronal: boolean;
  showObrero: boolean;
  showReservas: boolean;
}

export function FortnightReportTable({
  data,
  showPatronal,
  showObrero,
  showReservas,
}: FortnightReportTableProps) {
  const [scrolled, setScrolled] = useState(false);

  const rows = data.map((row) => {
    const salarioBruto = parseFloat(row.salariobruto.toString());
    const obreym = parseFloat(row.obreym);
    const obrivm = parseFloat(row.obrivm);
    const obrbanco = parseFloat(row.obrbanco);
    const obrsolidarista = parseFloat(row.obrsolidarista);
    const impuestorenta = parseFloat(row.impuestorenta);
    const pateym = parseFloat(row.pateym);
    const pativm = parseFloat(row.pativm);
    const resaguinaldo = parseFloat(row.resaguinaldo);
    const rescesantia = parseFloat(row.rescesantia);
    const resvacaciones = parseFloat(row.resvacaciones);

    const totalDeducciones = obreym + obrivm + obrbanco + obrsolidarista + impuestorenta;
    const porcentajeDeducciones = (totalDeducciones / (salarioBruto / 2)) * 100;
    const porcentajeRestante = 100 - porcentajeDeducciones;

    return (
      <Table.Tr key={row.cedula}>
        <Table.Td>
          <Anchor component="button" fz="sm">
            {row.cedula}
          </Anchor>
        </Table.Td>
        <Table.Td>{row.nombre}</Table.Td>
        <Table.Td>{row.depnombre}</Table.Td>
        <Table.Td>{new Date(row.fechapago).toLocaleDateString()}</Table.Td>
        <Table.Td>{Intl.NumberFormat().format(salarioBruto)}</Table.Td>
        {showPatronal && (
          <>
            <Table.Td>{pateym.toFixed(2)}</Table.Td>
            <Table.Td>{pativm.toFixed(2)}</Table.Td>
          </>
        )}
        {showObrero && (
          <>
            <Table.Td>{obreym.toFixed(2)}</Table.Td>
            <Table.Td>{obrivm.toFixed(2)}</Table.Td>
            <Table.Td>{obrbanco.toFixed(2)}</Table.Td>
            <Table.Td>{obrsolidarista.toFixed(2)}</Table.Td>
          </>
        )}
        {showReservas && (
          <>
            <Table.Td>{resaguinaldo.toFixed(2)}</Table.Td>
            <Table.Td>{rescesantia.toFixed(2)}</Table.Td>
            <Table.Td>{resvacaciones.toFixed(2)}</Table.Td>
          </>
        )}
        <Table.Td>
          <Group justify="space-between">
            <Text fz="xs" c="teal" fw={700}>
              {porcentajeRestante.toFixed(0)}%
            </Text>
            <Text fz="xs" c="red" fw={700}>
              {porcentajeDeducciones.toFixed(0)}%
            </Text>
          </Group>
          <Progress.Root>
            <Progress.Section
              className={classes.progressSection}
              value={porcentajeRestante}
              color="teal"
            />
            <Progress.Section
              className={classes.progressSection}
              value={porcentajeDeducciones}
              color="red"
            />
          </Progress.Root>
        </Table.Td>
        <Table.Td>{impuestorenta.toFixed(2)}</Table.Td>
      </Table.Tr>
    );
  });

  return (
    <ScrollArea
      onScrollPositionChange={({ y }) => setScrolled(y !== 0)}
      className={classes.scrollArea}
    >
      <Table miw={800} className={classes.table}>
        <Table.Thead className={cx(classes.header, { [classes.scrolled]: scrolled })}>
          <Table.Tr>
            <Table.Th rowSpan={2}>Cédula</Table.Th>
            <Table.Th rowSpan={2}>Nombre</Table.Th>
            <Table.Th rowSpan={2}>Departamento</Table.Th>
            <Table.Th rowSpan={2}>Fecha</Table.Th>
            <Table.Th rowSpan={2}>Salario Bruto</Table.Th>
            {showPatronal && <Table.Th colSpan={2}>Deducciones Patronales</Table.Th>}
            {showObrero && <Table.Th colSpan={4}>Deducciones Obrero</Table.Th>}
            {showReservas && <Table.Th colSpan={3}>Reservas</Table.Th>}
            <Table.Th rowSpan={2}>Deducciones %</Table.Th>
            <Table.Th rowSpan={2}>Impuesto Renta</Table.Th>
          </Table.Tr>
          <Table.Tr>
            {showPatronal && (
              <>
                <Table.Th>Pat EYM</Table.Th>
                <Table.Th>Pat IVM</Table.Th>
              </>
            )}
            {showObrero && (
              <>
                <Table.Th>Obr EYM</Table.Th>
                <Table.Th>Obr IVM</Table.Th>
                <Table.Th>Banco</Table.Th>
                <Table.Th>Solidarista</Table.Th>
              </>
            )}
            {showReservas && (
              <>
                <Table.Th>Aguinaldo</Table.Th>
                <Table.Th>Cesantía</Table.Th>
                <Table.Th>Vacaciones</Table.Th>
              </>
            )}
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>{rows}</Table.Tbody>
      </Table>
    </ScrollArea>
  );
}

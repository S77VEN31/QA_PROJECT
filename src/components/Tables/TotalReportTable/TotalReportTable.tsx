// React
import { useState } from 'react';
// Types
import { ReportTotalData } from '@types';
// Tools
import cx from 'clsx';
// Mantine
import { Group, Progress, ScrollArea, Table, Text } from '@mantine/core';
// Classes
import classes from './TotalReportTable.module.css';

// Interfaces
interface TotalTableProps {
  data: ReportTotalData[];
  showPatronal: boolean;
  showObrero: boolean;
  showReservas: boolean;
}

export function TotalReportTable({
  data,
  showPatronal,
  showObrero,
  showReservas,
}: TotalTableProps) {
  const [scrolled, setScrolled] = useState(false);

  const rows = data.map((row, index) => {
    console.log(row, index);
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
    const salarioNeto = salarioBruto - 2 * totalDeducciones;
    const porcentajeDeducciones = (totalDeducciones / (salarioBruto / 2)) * 100;
    const porcentajeRestante = 100 - porcentajeDeducciones;

    return (
      <Table.Tr key={index}>
        <Table.Td>
          {salarioBruto.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' })}
        </Table.Td>
        <Table.Td>
          {salarioNeto.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' })}
        </Table.Td>
        <Table.Td aria-hidden>
          <Group justify="space-between">
            <Text fz="xs" c="teal" fw={700}>
              {porcentajeRestante.toFixed(0)}%
            </Text>
            <Text fz="xs" c="red" fw={700}>
              {porcentajeDeducciones.toFixed(0)}%
            </Text>
          </Group>
          <Progress.Root aria-hidden>
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
        <Table.Td>
          {impuestorenta.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' })}
        </Table.Td>
        {showObrero && (
          <>
            <Table.Td>
              {obreym.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' })}
            </Table.Td>
            <Table.Td>
              {obrivm.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' })}
            </Table.Td>
            <Table.Td>
              {obrbanco.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' })}
            </Table.Td>
            <Table.Td>
              {obrsolidarista.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' })}
            </Table.Td>
          </>
        )}
        {showPatronal && (
          <>
            <Table.Td>
              {pateym.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' })}
            </Table.Td>
            <Table.Td>
              {pativm.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' })}
            </Table.Td>
          </>
        )}
        {showReservas && (
          <>
            <Table.Td>
              {resaguinaldo.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' })}
            </Table.Td>
            <Table.Td>
              {rescesantia.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' })}
            </Table.Td>
            <Table.Td>
              {resvacaciones.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' })}
            </Table.Td>
          </>
        )}
      </Table.Tr>
    );
  });

  return (
    <ScrollArea
      onScrollPositionChange={({ y }) => setScrolled(y !== 0)}
      className={classes.scrollArea}
    >
      <Table miw={800} className={classes.table}>
        <Table.Caption>Tabla de reportes totales</Table.Caption>
        <Table.Thead className={cx(classes.header, { [classes.scrolled]: scrolled })}>
          <Table.Tr>
            <Table.Th rowSpan={2}>Salario Bruto</Table.Th>
            <Table.Th rowSpan={2}>Salario Neto</Table.Th>
            <Table.Th rowSpan={2} aria-hidden>
              Deducciones %
            </Table.Th>
            <Table.Th rowSpan={2}>Impuesto Renta</Table.Th>
            {showObrero && <Table.Th colSpan={4}>Deducciones Obrero</Table.Th>}
            {showPatronal && <Table.Th colSpan={2}>Deducciones Patronales</Table.Th>}
            {showReservas && <Table.Th colSpan={3}>Reservas Patronales</Table.Th>}
          </Table.Tr>
          <Table.Tr>
            {showObrero && (
              <>
                <Table.Th>EyM</Table.Th>
                <Table.Th>IVM</Table.Th>
                <Table.Th>Banco</Table.Th>
                <Table.Th>Solidarista</Table.Th>
              </>
            )}
            {showPatronal && (
              <>
                <Table.Th>EyM</Table.Th>
                <Table.Th>IVM</Table.Th>
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

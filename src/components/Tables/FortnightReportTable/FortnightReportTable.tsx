// React
import { useContext, useState } from 'react';
// Types
import { ReportDetailData } from '@types';
// Tools
import cx from 'clsx';
import { Link } from 'react-router-dom';
// Mantine
import { Group, Progress, ScrollArea, Table, Text } from '@mantine/core';
// Contexts
import { FocusContext } from '@/contexts';
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
  const formatCurrency = (value: number): string => {
    return value.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' });
  };
  const headers = [
    'Cédula',
    'Nombre',
    'Departamento',
    'Fecha',
    'Salario Bruto',
    'Salario Neto',
    'Deducciones %',
    'Impuesto Renta',
  ];
  const obreroHeaders = ['EyM', 'IVM', 'Banco', 'Solidarista'];
  const patronalHeaders = ['EyM', 'IVM'];
  const reservaHeaders = ['Aguinaldo', 'Cesantía', 'Vacaciones'];
  const getHeaders = (headers: string[], rowSpan?: number): JSX.Element[] => {
    return headers.map((header, index) => (
      <Table.Th key={index} aria-label={header} rowSpan={rowSpan}>
        {header}
      </Table.Th>
    ));
  };
  const getRows = (values: number[]): JSX.Element[] => {
    return values.map((value, index) => <Table.Td key={index}>{formatCurrency(value)}</Table.Td>);
  };

  const rows = data.map((row) => {
    const propsToParse = [
      'salariobruto',
      'obreym',
      'obrivm',
      'obrbanco',
      'obrsolidarista',
      'impuestorenta',
      'pateym',
      'pativm',
      'resaguinaldo',
      'rescesantia',
      'resvacaciones',
    ] as const;

    const parsedValues = propsToParse.reduce(
      (acc, prop) => {
        acc[prop] = parseFloat(String(row[prop]));
        return acc;
      },
      {} as Record<string, number>
    );

    const {
      salariobruto,
      obreym,
      obrivm,
      obrbanco,
      obrsolidarista,
      impuestorenta,
      pateym,
      pativm,
      resaguinaldo,
      rescesantia,
      resvacaciones,
    } = parsedValues;

    const creditosfiscales = row.creditosfiscales;

    const totalDeducciones = obreym + obrivm + obrbanco + obrsolidarista + impuestorenta;
    const salarioNeto = salariobruto - 2 * totalDeducciones;
    const porcentajeDeducciones = (totalDeducciones / (salariobruto / 2)) * 100;
    const porcentajeRestante = 100 - porcentajeDeducciones;

    const obreroValores = [obreym, obrivm, obrbanco, obrsolidarista];
    const patronalValores = [pateym, pativm];
    const reservaValores = [resaguinaldo, rescesantia, resvacaciones];

    const focusContext = useContext(FocusContext);
    return (
      <Table.Tr key={row.cedula}>
        <Table.Td>
          <Link
            to={`/dashboard/collaborators/assign-salary?cardID=${row.cedula}`}
            style={{ fontSize: 'small' }}
            aria-label={`Ver datos de ${row.nombre}`}
            onClick={focusContext?.focusContent}
          >
            {row.cedula}
          </Link>
        </Table.Td>
        <Table.Th scope="row">{row.nombre}</Table.Th>
        <Table.Td>{row.depnombre}</Table.Td>
        <Table.Td>{new Date(row.fechapago).toLocaleDateString()}</Table.Td>
        {getRows([salariobruto])}
        {getRows([salarioNeto])}
        <Table.Td>
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
        <Table.Td
          style={{
            backgroundColor: creditosfiscales ? 'rgba(255, 0, 0, 0.1)' : 'transparent',
          }}
          aria-label={
            creditosfiscales ? `${impuestorenta} Este colaborador tiene créditos fiscales` : ''
          }
        >
          {formatCurrency(impuestorenta)}
        </Table.Td>
        {showObrero && <>{getRows(obreroValores)}</>}
        {showPatronal && <>{getRows(patronalValores)}</>}
        {showReservas && <>{getRows(reservaValores)}</>}
      </Table.Tr>
    );
  });

  return (
    <ScrollArea
      onScrollPositionChange={({ y }) => setScrolled(y !== 0)}
      className={classes.scrollArea}
    >
      <Table miw={800} className={classes.table}>
        <Table.Caption>Tabla de reportes detallados</Table.Caption>
        <Table.Thead className={cx(classes.header, { [classes.scrolled]: scrolled })}>
          <Table.Tr>
            {getHeaders(headers, 2)}
            {showObrero && <Table.Th colSpan={4}>Deducciones Obrero</Table.Th>}
            {showPatronal && <Table.Th colSpan={2}>Deducciones Patronales</Table.Th>}
            {showReservas && <Table.Th colSpan={3}>Reservas Patronales</Table.Th>}
          </Table.Tr>
          <Table.Tr>
            {showObrero && <>{getHeaders(obreroHeaders)}</>}
            {showPatronal && <>{getHeaders(patronalHeaders)}</>}
            {showReservas && <>{getHeaders(reservaHeaders)}</>}
          </Table.Tr>
        </Table.Thead>
        <Table.Tbody>{rows}</Table.Tbody>
      </Table>
    </ScrollArea>
  );
}

// React
import { useState } from 'react';
// API
import { insertFortnight, insertNFortnights } from '@api';
// Mantine
import { Button, Container, Group, Text, Title } from '@mantine/core';
import { DateInput } from '@mantine/dates';
import { notifications } from '@mantine/notifications';
import { NotificationPosition } from '@mantine/notifications/lib/notifications.store';
// Classes
import classes from './Fortnight.page.module.css';

const defaultNotificationPosition: NotificationPosition = 'top-center';
const notificationMessages = {
  loadingToast: (date: string, n?: number) => ({
    title: 'Por favor espere.',
    message: n
      ? `Se están generando ${n} quincenas a partir del día ${date}.`
      : `Se está generando la planilla para el día ${date}.`,
    loading: true,
    id: 'fortnight-loading',
    position: defaultNotificationPosition,
    autoClose: false,
  }),
  successToast: (date: string, n?: number) => ({
    title: 'Quincena generada',
    message: n
      ? `Se han generado ${n} quincenas a partir del día ${date}.`
      : `Se ha generado la quincena para el día ${date}.`,
    color: 'blue',
    position: defaultNotificationPosition,
  }),
  errorToast: (error: string) => ({
    title: 'Error',
    message: error,
    color: 'red',
    position: defaultNotificationPosition,
  }),
  invalidDate: {
    title: 'Fecha inválida',
    message: 'Seleccione el 14 o 28.',
    color: 'red',
    position: defaultNotificationPosition,
  },
  selectDate: {
    title: 'Seleccione una fecha',
    message: 'Debe seleccionar una fecha.',
    color: 'red',
    position: defaultNotificationPosition,
  },
};

type NullableDate = Date | null;

export function FortnightPage() {
  const [quincenaDate, setQuincenaDate] = useState<NullableDate>(null);
  const [multiQuincenaDate, setMultiQuincenaDate] = useState<NullableDate>(null);
  const [loading, setLoading] = useState(false);

  const { loadingToast, successToast, errorToast, invalidDate, selectDate } = notificationMessages;

  // Filtrar las fechas para permitir solo el 14 o el 28 de cada mes
  const filterQuincenaDays = (date: Date) => {
    const day = date.getDate();
    return day === 14 || day === 28;
  };

  const validateDate = (date: NullableDate): boolean => {
    const day = date?.getDate();
    if (day !== 14 && day !== 28) {
      notifications.show(invalidDate);
      return false;
    }
    return true;
  };

  const handleNotification = async (date: NullableDate, n?: number, apiCall?: any) => {
    if (!validateDate(date)) {
      return;
    }

    if (date instanceof Date) {
      setLoading(true);
      const dateString = date.toDateString();
      notifications.show(loadingToast(dateString, n));
      try {
        await apiCall();
        notifications.show(successToast(dateString, n));
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'Ha ocurrido un error.';
        notifications.show(errorToast(errorMessage));
      } finally {
        notifications.hide('fortnight-loading');
        setLoading(false);
      }
    } else {
      notifications.show(selectDate);
    }
  };

  return (
    <div>
      <header className={classes.header}>
        <Title>Generar pagos de quincenas</Title>
        <Text>Genera pagos solo los días 14 y 28 de cada mes.</Text>
      </header>
      <main className={classes.mainLayout}>
        <Container fluid>
          <Title order={2}>Insertar una quincena</Title>
          <DateInput
            label="Fecha"
            value={quincenaDate}
            onChange={setQuincenaDate}
            valueFormat="DD-MM-YYYY"
            excludeDate={(date) => !filterQuincenaDays(date)} // Filtrar días permitidos
          />
          <Button
            mt="md"
            onClick={() =>
              handleNotification(quincenaDate, undefined, () =>
                insertFortnight({ timestamp: quincenaDate as Date })
              )
            }
            disabled={loading}
          >
            Generar
          </Button>

          <Title order={2} mt="xl">
            Insertar múltiples quincenas
          </Title>
          <DateInput
            label="Fecha de inicio"
            value={multiQuincenaDate}
            onChange={setMultiQuincenaDate}
            valueFormat="DD-MM-YYYY"
            excludeDate={(date) => !filterQuincenaDays(date)} // Filtrar días permitidos
          />
          <Group mt="md">
            <Button
              onClick={() =>
                handleNotification(multiQuincenaDate, 5, () =>
                  insertNFortnights({ timestamp: multiQuincenaDate as Date, n: 5 })
                )
              }
              disabled={loading}
            >
              Generar 5 quincenas
            </Button>
            <Button
              onClick={() =>
                handleNotification(multiQuincenaDate, 10, () =>
                  insertNFortnights({ timestamp: multiQuincenaDate as Date, n: 10 })
                )
              }
              disabled={loading}
            >
              Generar 10 quincenas
            </Button>
          </Group>
        </Container>
      </main>
    </div>
  );
}

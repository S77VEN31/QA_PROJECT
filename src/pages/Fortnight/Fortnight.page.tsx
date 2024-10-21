// React
import { useState } from 'react';
// API
import {
  insertFortnight,
  insertNFortnights,
  MultipleFortnightsParams,
  SingleFortnightParams,
} from '@api';
// Mantine
import { Button, Container, Group, Text, Title } from '@mantine/core';
import { DateInput } from '@mantine/dates';
import { useForm } from '@mantine/form';
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
    withCloseButton: false,
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
  // const [quincenaDate, setQuincenaDate] = useState<NullableDate>(null);
  // const [multiQuincenaDate, setMultiQuincenaDate] = useState<NullableDate>(null);
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
      const dateString = date.toLocaleString('es-Es', {
        day: 'numeric',
        month: 'long',
        year: 'numeric',
      });
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

  const singleFortnightForm = useForm({
    initialValues: {
      quincenaDate: null,
    } as SingleFortnightParams,
    validate: {
      quincenaDate: (value: NullableDate) => {
        return validateDate(value) ? null : 'Seleccione el 14 o 28.';
      },
    },
  });

  const handleInsertSingleFortnight = async (body: SingleFortnightParams) => {
    const quincenaDate = body.quincenaDate as Date;
    handleNotification(quincenaDate, undefined, () =>
      insertFortnight({ timestamp: quincenaDate as Date })
    ).then((_) => singleFortnightForm.reset());
  };

  const multipleFortnightForm = useForm({
    initialValues: {
      quincenaDate: null,
      n: 5,
    } as MultipleFortnightsParams,
    validate: {
      quincenaDate: (value: NullableDate) => {
        return validateDate(value) ? null : 'Seleccione el 14 o 28.';
      },
      n: (value: number) => {
        return value == 5 || value == 10 ? null : 'Ingrese un número mayor a 0.';
      },
    },
  });

  const handleInsertMultipleFortnights = async (body: MultipleFortnightsParams, event?: any) => {
    const quincenaDate = body.quincenaDate as Date;
    const n = parseInt(event.nativeEvent.submitter.value);
    handleNotification(quincenaDate, n, () =>
      insertNFortnights({ timestamp: quincenaDate as Date, n })
    ).then((_) => multipleFortnightForm.reset());
  };

  return (
    <div>
      <header className={classes.header}>
        <Title>Generar pagos de quincenas</Title>
        <Text>Genera pagos solo los días 14 y 28 de cada mes.</Text>
      </header>
      <main className={classes.mainLayout}>
        <Container fluid>
          <form onSubmit={singleFortnightForm.onSubmit(handleInsertSingleFortnight)}>
            <Title order={2}>Insertar una quincena</Title>
            <DateInput
              label="Fecha"
              aria-label="Ingrese la fecha para insertar una única quincena."
              placeholder="Seleccione el día 14 o 28"
              required
              {...singleFortnightForm.getInputProps('quincenaDate')}
              value={singleFortnightForm.values.quincenaDate}
              onChange={(event) => singleFortnightForm.setFieldValue('quincenaDate', event)}
              valueFormat="DD-MM-YYYY"
              excludeDate={(date) => !filterQuincenaDays(date)} // Filtrar días permitidos
              clearable
            />
            <Button mt="md" type="submit" disabled={loading}>
              Generar
            </Button>
          </form>

          <form onSubmit={multipleFortnightForm.onSubmit(handleInsertMultipleFortnights)}>
            <Title order={2} mt="xl">
              Insertar múltiples quincenas
            </Title>
            <DateInput
              label="Fecha de inicio"
              aria-label="Ingrese la fecha para insertar múltiples quincenas."
              required
              {...multipleFortnightForm.getInputProps('quincenaDate')}
              value={multipleFortnightForm.values.quincenaDate}
              onChange={(event) => multipleFortnightForm.setFieldValue('quincenaDate', event)}
              valueFormat="DD-MM-YYYY"
              excludeDate={(date) => !filterQuincenaDays(date)}
              placeholder="Seleccione el día 14 o 28"
            />
            <Group mt="md">
              <Button type="submit" value="5" disabled={loading}>
                Generar 5 quincenas
              </Button>
              <Button type="submit" value="10" disabled={loading}>
                Generar 10 quincenas
              </Button>
            </Group>
            <Text mt={'md'}>Si la quincena ya se había pagado, no se duplican los pagos.</Text>
          </form>
        </Container>
      </main>
    </div>
  );
}

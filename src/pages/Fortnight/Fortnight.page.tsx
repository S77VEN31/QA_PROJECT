/* eslint-disable no-template-curly-in-string */
import { insertFortnight, insertNFortnights } from '@/api';
import { Button, Container, Group, Text, Title } from '@mantine/core';
import { DateInput } from '@mantine/dates';
import { notifications } from '@mantine/notifications';
import { useState } from 'react';
import classes from './Fortnight.page.module.css';

// Centralized notifications JSON object

const notificationMessages = {
  loadingFortnight: {
    title: 'Por favor espere.',
    message: 'Se está generando la planilla para el día ${date}. Esto podría tardar 1 o 2 minutos.',
    loading: true,
    withCloseButton: false,
    id: 'fortnight-loading',
    position: 'top-center',
    autoClose: false,
  },
  successFortnight: {
    title: 'Quincena generada',
    message: 'Se ha generado la quincena para el día ${date}',
    color: 'blue',
    position: 'top-center',
  },
  errorFortnight: {
    title: 'Error',
    message: '${error}',
    color: 'red',
    position: 'top-center',
  },
  invalidDate: {
    title: 'Fecha inválida',
    message: 'Por favor seleccione una fecha donde el día sea 14 o 28',
    color: 'red',
    position: 'top-center',
  },
  loadingMultipleFortnights: {
    title: 'Por favor espere.',
    message:
      'Se están generando ${n} quincenas a partir del día ${date}. Esto podría tardar varios minutos.',
    loading: true,
    withCloseButton: false,
    id: 'fortnight-loading',
    position: 'top-center',
    autoClose: false,
  },
  successMultipleFortnights: {
    title: 'Quincenas generadas',
    message: 'Se han generado ${n} quincenas a partir del día ${date}',
    color: 'blue',
    position: 'top-center',
  },
  selectDate: {
    title: 'Por favor seleccione una fecha',
    message: 'Debe seleccionar una fecha para generar las quincenas',
    color: 'red',
    position: 'top-center',
  },
};

// Utility function to replace placeholders in messages
const replacePlaceholders = (message: string, variables: { [key: string]: string }) => {
  return message.replace(/\${(.*?)}/g, (_, key) => variables[key] || '');
};

type NullableDate = Date | null;

export function FortnightPage() {
  const [quincenaDate, setQuincenaDate] = useState<NullableDate>(null);
  const [multiQuincenaDate, setMultiQuincenaDate] = useState<NullableDate>(null);
  const [loading, setLoading] = useState(false);

  // Function to validate that only 14th or 28th can be selected
  const validateDate = (date: NullableDate): boolean => {
    if (!date) {
      return true;
    }
    const day = date.getDate();
    if (day !== 14 && day !== 28) {
      notifications.show({
        ...notificationMessages.invalidDate,
        position: notificationMessages.invalidDate.position as 'top-center', // Cast to NotificationPosition
      });
      return false;
    }
    return true;
  };

  const handleQuincenaChange = (value: NullableDate) => {
    if (validateDate(value)) {
      setQuincenaDate(value);
    }
  };

  const handleMultiQuincenaChange = (value: NullableDate) => {
    if (validateDate(value)) {
      setMultiQuincenaDate(value);
    }
  };

  const handleInsertFortnight = async () => {
    if (quincenaDate) {
      setLoading(true);

      const message = replacePlaceholders(notificationMessages.loadingFortnight.message, {
        date: quincenaDate.toDateString(),
      });

      notifications.show({
        ...notificationMessages.loadingFortnight,
        message,
        position: notificationMessages.loadingFortnight.position as 'top-center', // Cast to NotificationPosition
      });

      try {
        await insertFortnight({ timestamp: quincenaDate });

        const successMessage = replacePlaceholders(notificationMessages.successFortnight.message, {
          date: quincenaDate.toDateString(),
        });

        notifications.show({
          ...notificationMessages.successFortnight,
          message: successMessage,
          position: notificationMessages.successFortnight.position as 'top-center', // Cast to NotificationPosition
        });
      } catch (error) {
        const errorMessage = replacePlaceholders(notificationMessages.errorFortnight.message, {
          error: error instanceof Error ? error.message : 'Ha ocurrido un error',
        });

        notifications.show({
          ...notificationMessages.errorFortnight,
          message: errorMessage,
          position: notificationMessages.errorFortnight.position as 'top-center', // Cast to NotificationPosition
        });
      } finally {
        notifications.hide('fortnight-loading');
        setLoading(false);
      }
    } else {
      notifications.show({
        ...notificationMessages.selectDate,
        position: notificationMessages.selectDate.position as 'top-center', // Cast to NotificationPosition
      });
    }
  };

  const handleInsertNFortnights = async (n: number) => {
    if (multiQuincenaDate) {
      setLoading(true);

      const message = replacePlaceholders(notificationMessages.loadingMultipleFortnights.message, {
        date: multiQuincenaDate.toDateString(),
        n: n.toString(),
      });

      notifications.show({
        ...notificationMessages.loadingMultipleFortnights,
        message,
        position: notificationMessages.loadingMultipleFortnights.position as 'top-center', // Cast to NotificationPosition
      });

      try {
        await insertNFortnights({ timestamp: multiQuincenaDate, n });

        const successMessage = replacePlaceholders(
          notificationMessages.successMultipleFortnights.message,
          {
            date: multiQuincenaDate.toDateString(),
            n: n.toString(),
          }
        );

        notifications.show({
          ...notificationMessages.successMultipleFortnights,
          message: successMessage,
          position: notificationMessages.successMultipleFortnights.position as 'top-center', // Cast to NotificationPosition
        });
      } catch (error) {
        const errorMessage = replacePlaceholders(notificationMessages.errorFortnight.message, {
          error: error instanceof Error ? error.message : 'Ha ocurrido un error',
        });

        notifications.show({
          ...notificationMessages.errorFortnight,
          message: errorMessage,
          position: notificationMessages.errorFortnight.position as 'top-center', // Cast to NotificationPosition
        });
      } finally {
        notifications.hide('fortnight-loading');
        setLoading(false);
      }
    } else {
      notifications.show({
        ...notificationMessages.selectDate,
        position: notificationMessages.selectDate.position as 'top-center', // Cast to NotificationPosition
      });
    }
  };

  return (
    <div>
      <header className={classes.header}>
        <Title>Generar pagos de quincenas</Title>
        <Text>
          Podrá generar los pagos de la planilla para una quincena. La quincena no debe estar
          pagada. Los pagos deben realizarse solo los días 14 y 28 de cada mes.
        </Text>
      </header>
      <main className={classes.mainLayout}>
        <Container fluid>
          <Title order={2}>Insertar una quincena</Title>
          <DateInput
            label="Fecha:"
            placeholder="Selecciona el 14 o el 28"
            value={quincenaDate}
            onChange={handleQuincenaChange}
            valueFormat="DD-MM-YYYY"
            mx="auto"
            aria-label="Fecha de quincena"
          />
          <Button mt="md" onClick={handleInsertFortnight} disabled={loading}>
            Generar
          </Button>

          <Title order={2} mt="xl">
            Insertar múltiples quincenas
          </Title>
          <Text>
            Puede generar múltiples quincenas a la vez. Ingrese la fecha a partir de la cual se
            generarán los pagos. Si una quincena ya tiene pagos, no se generará.
          </Text>
          <DateInput
            label="Fecha de inicio"
            placeholder="Selecciona el 14 o el 28"
            value={multiQuincenaDate}
            onChange={handleMultiQuincenaChange}
            valueFormat="DD-MM-YYYY"
            mx="auto"
            aria-label="Fecha de inicio de quincena"
          />
          <Group mt="md">
            <Button onClick={() => handleInsertNFortnights(5)} disabled={loading}>
              Generar 5 quincenas
            </Button>
            <Button onClick={() => handleInsertNFortnights(10)} disabled={loading}>
              Generar 10 quincenas
            </Button>
          </Group>
        </Container>
      </main>
    </div>
  );
}

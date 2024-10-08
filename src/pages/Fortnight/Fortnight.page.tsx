import { useState } from 'react';
import { Button, Container, Group, Notification, Text, Title } from '@mantine/core';
import { DateInput } from '@mantine/dates';
import { notifications } from '@mantine/notifications';
import { insertFortnight, insertNFortnights } from '@/api';
import classes from './Fortnight.page.module.css';

// Define the types for the component state
type NullableDate = Date | null;

export function FortnightPage() {
  const [quincenaDate, setQuincenaDate] = useState<NullableDate>(null);
  const [multiQuincenaDate, setMultiQuincenaDate] = useState<NullableDate>(null);
  const [loading, setLoading] = useState(false);

  // Function to validate that only 14th or 28th can be selected
  const validateDate = (date: NullableDate): boolean => {
    if (!date) return true; // allow empty date selection
    const day = date.getDate();
    if (day !== 14 && day !== 28) {
      notifications.show({
        title: 'Fecha inválida',
        message: 'Por favor seleccione una fecha donde el día sea 14 o 28',
        color: 'red',
        position: 'top-center',
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
    console.log('Inserting quincena', quincenaDate);
    if (quincenaDate) {
      setLoading(true);
      notifications.show({
        title: 'Por favor espere.',
        message: `Se está generando la planilla para el día ${quincenaDate.toDateString()}. Esto podría tardar 1 o 2 minutos`,
        loading: true,
        withCloseButton: false,
        id: 'fortnight-loading',
        position: 'top-center',
        autoClose: false,
      });
      try {
        await insertFortnight({ timestamp: quincenaDate });
        notifications.show({
          title: 'Quincena generada',
          message: `Se ha generado la quincena para el día ${quincenaDate.toDateString()}`,
          color: 'blue',
          position: 'top-center',
        });
      } catch (error) {
        if (error instanceof Error) {
          notifications.show({
            title: 'Error',
            message: error.message,
            color: 'red',
            position: 'top-center',
          });
        } else {
          notifications.show({
            title: 'Error',
            message: 'Ha ocurrido un error al generar la quincena',
            color: 'red',
            position: 'top-center',
          });
        }
      } finally {
        notifications.hide('fortnight-loading');
        setLoading(false);
      }
    } else {
      notifications.show({
        title: 'Por favor seleccione una fecha',
        message: 'Debe seleccionar una fecha para generar la quincena',
        color: 'red',
        position: 'top-center',
      });
    }
  };

  const handleInsertNFortnights = async (n: number) => {
    console.log('Inserting n quincenas', n);
    if (multiQuincenaDate) {
      setLoading(true);
      notifications.show({
        title: 'Por favor espere.',
        message: `Se están generando ${n} quincenas a partir del día ${multiQuincenaDate.toDateString()}. Esto podría tardar varios minutos.`,
        loading: true,
        withCloseButton: false,
        id: 'fortnight-loading',
        position: 'top-center',
        autoClose: false,
      });
      try {
        await insertNFortnights({ timestamp: multiQuincenaDate, n });
        notifications.show({
          title: 'Quincenas generadas',
          message: `Se han generado ${n} quincenas a partir del día ${multiQuincenaDate.toDateString()}`,
          color: 'blue',
          position: 'top-center',
        });
      } catch (error) {
        if (error instanceof Error) {
          notifications.show({
            title: 'Error',
            message: error.message,
            color: 'red',
            position: 'top-center',
          });
        } else {
          notifications.show({
            title: 'Error',
            message: 'Ha ocurrido un error al generar las quincenas.',
            color: 'red',
            position: 'top-center',
          });
        }
      } finally {
        notifications.hide('fortnight-loading');
        setLoading(false);
      }
    } else {
      notifications.show({
        title: 'Por favor seleccione una fecha',
        message: 'Debe seleccionar una fecha para generar las quincenas',
        color: 'red',
        position: 'top-center',
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
              Generar 5 meses
            </Button>
          </Group>
        </Container>
      </main>
    </div>
  );
}

// React
import { useState } from 'react';
// API
import { calculateTax } from '@api';
// Mantine
import { Button, Container, Group, NumberInput, Switch, Text, Title } from '@mantine/core';
import { useForm } from '@mantine/form';
import { notifications } from '@mantine/notifications';
import { NotificationPosition } from '@mantine/notifications/lib/notifications.store';
// Classes
import classes from './Calculator.module.css';

// Define the types for the form values
interface CalculatorFormValues {
  salary: number;
}

const defaultNotificationPosition: NotificationPosition = 'top-center';
const notificationMessages = {
  successToast: (tax: number) => ({
    title: 'Impuesto calculado',
    message: `El impuesto de renta es de ${tax.toFixed(2)} colones.`,
    color: 'green',
    position: defaultNotificationPosition,
  }),
  errorToast: {
    title: 'Error al calcular impuesto',
    message: 'Ocurrió un error inesperado, inténtelo de nuevo',
    color: 'red',
    position: defaultNotificationPosition,
  },
};

export function CalculatorPage() {
  const [tax, setTax] = useState<number | null>(null);
  // Using useForm hook to manage form values and validation
  const form = useForm<CalculatorFormValues>({
    initialValues: {
      salary: 0,
    },
    validate: {
      salary: (value) => (value > 0 ? null : 'El salario debe ser mayor que 0'),
    },
  });

  const { successToast, errorToast } = notificationMessages;

  // Submit handler for the form
  const handleSubmit = (values: CalculatorFormValues) => {
    // Handle form submission logic here
    const params = {
      salary: values.salary,
    };
    // Call the API to calculate the income tax
    calculateTax(params)
      .then((response) => {
        const [data] = response;
        const tax = parseFloat(data.calculate_tax);
        notifications.show(successToast(tax));
        setTax(tax);
      })
      .catch((error) => {
        console.log(error);
        notifications.show(errorToast);
      });
  };

  return (
    <div className={classes.mainLayout}>
      <header className={classes.header}>
        <Title order={2} mt="xl" mb="md">
          Calculadora del impuesto de renta
        </Title>
        <Text>
          Ingrese los datos para calcular el impuesto de renta de un colaborador con base en su
          salario.
        </Text>
      </header>
      <main className={classes.main}>
        <form onSubmit={form.onSubmit(handleSubmit)} className={classes.formContainer}>
          <div className={classes.inputsContainer}>
            <NumberInput
              hideControls
              className={classes.input}
              {...form.getInputProps('salary')}
              value={form.values.salary || ''}
              onChange={(value) => form.setFieldValue('salary', value as number)}
              placeholder="Ingrese el salario"
              label="Salario"
              aria-label="Ingrese el salario"
              allowDecimal={false}
              allowNegative={false}
              required
            />
          </div>
          <div className={classes.buttonContainer}>
            <Button type="submit">Calcular impuesto de renta</Button>
          </div>
        </form>
        <div>
          {tax !== null && (
            <Group mt={'md'}>
              <Text>
                El impuesto de renta a pagar es de{' '}
                <strong>
                  {tax.toLocaleString('es-CR', { style: 'currency', currency: 'CRC' })}
                </strong>
              </Text>
            </Group>
          )}
        </div>
      </main>
    </div>
  );
}

// API
import { createDepartment, CreateDepartmentParams } from '@api';
// Mantine
import { Button, Text, TextInput, Title } from '@mantine/core';
import { useForm } from '@mantine/form';
import { notifications } from '@mantine/notifications';
import { NotificationPosition } from '@mantine/notifications/lib/notifications.store';
// Classes
import classes from './CreateDepartment.page.module.css';

const defaultNotificationPosition: NotificationPosition = 'top-center';

const notificationMessages = {
  successToast: {
    title: 'Operación exitosa',
    message: 'El departamento se creó correctamente',
    color: 'green',
    position: defaultNotificationPosition,
  },
  errorToast: (message: string) => ({
    title: 'Error al crear departamento',
    message,
    color: 'red',
    position: defaultNotificationPosition,
  }),
};

export function CreateDepartmentPage() {
  const form = useForm({
    initialValues: {
      departmentName: '',
    } as CreateDepartmentParams,
    validate: {
      departmentName: (value) =>
        value.length > 0 ? null : 'El nombre del departamento es obligatorio',
    },
  });

  const handleInsertDepartment = async (body: CreateDepartmentParams) => {
    createDepartment(body)
      .then((_) => {
        notifications.show(notificationMessages.successToast);
      })
      .catch((error) => {
        notifications.show(notificationMessages.errorToast(error.response?.data?.message));
      });
  };

  return (
    <div className={classes.mainLayout}>
      <header className={classes.header}>
        <Title>Crear un departamento</Title>
        <Text>Aquí puede insertar un nuevo departamento al sistema.</Text>
      </header>
      <main className={classes.main}>
        <form onSubmit={form.onSubmit(handleInsertDepartment)}>
          <div className={classes.inputsContainer}>
            <TextInput
              className={classes.input}
              placeholder="Ingrese el nombre del departamento"
              label="Nombre del departamento"
              aria-label="Nombre del departamento"
              {...form.getInputProps('depName')}
            />
          </div>
          <div className={classes.buttonContainer}>
            <Button type="submit">Crear un departamento</Button>
          </div>
        </form>
      </main>
    </div>
  );
}

// React
import { useState } from 'react';
// API
import { insertDepartment } from '@api';
// Components
import { Button } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { NotificationPosition } from '@mantine/notifications/lib/notifications.store';
import { TextInput } from '@mantine/core';
// Types

// Classes
import classes from './InsertDepartment.page.module.css';

const defaultNotificationPosition: NotificationPosition = 'top-center';
const notificationMessages = {
  successToast: (responseData: any) => ({
    title: 'Operación exitosa',
    message: responseData.message || 'El departamento se creó correctamente',
    color: 'green',
    position: defaultNotificationPosition,
  }),
  errorToast: (error: any) => ({
    title: 'Error al crear departamento',
    message: error.response?.data?.message || 'El departamento ya existe',
    color: 'red',
    position: defaultNotificationPosition,
  }),
  invalidFields: {
    title: 'Error al crear departamento',
    message: 'El nombre no es válido',
    color: 'red',
    position: defaultNotificationPosition,
  },
};

export function InsertDepartmentPage() {
  const [depName, setDepName] = useState<string>("");

  const { successToast, errorToast, invalidFields } = notificationMessages;

  function handleInsertDepartment() {
    {
      console.log('Creating department:', depName);
      if (depName) {
        // Call the function to assign the salary
        insertDepartment(depName)
          .then((responseData) => {
            // Display a success notification with the response body
            notifications.show(successToast(responseData));
          })
          .catch((error) => {
            // Handle and show error notification
            notifications.show(errorToast(error));
            console.error('Error creating department:', error);
          });
      } else {
        notifications.show(invalidFields);
      }
    }
  }
  return (
    <div className={classes.mainLayout}>
      <header className={classes.header}>
      </header>
        <main className={classes.main}>
          <h1>Crear un departamento</h1>
          <p>Aquí puede insertar un nuevo departamento al sistema.</p>
          <div className={classes.inputsContainer}>
            <TextInput
              value={depName}               // Bound to salary state
              onChange={(event) => setDepName(event.currentTarget.value)}  // Update salary state on change
              placeholder="Ingrese el nombre del departamento"  // Placeholder text
              label="Ingrese el nombre del departamento"
              aria-label="Nombre del departamento"
            />
          </div>
          <div className={classes.buttonContainer}>
            <Button
              onClick={handleInsertDepartment}
            >Crear</Button>
          </div>
        </main>
      <footer className={classes.footer}>
      </footer>
    </div>
  );
}

// React
import { useEffect, useState } from 'react';
// API
import { assignDepartmentSalary, getDepartments } from '@api';
// Components
import { SearchableSelect } from '@components';
import { IconPlus } from '@tabler/icons-react';
import { Button, NumberInput } from '@mantine/core';
import { notifications } from '@mantine/notifications';
import { NotificationPosition } from '@mantine/notifications/lib/notifications.store';
// Types

// Classes
import classes from '../DepartmentSalary.page.module.css';

const defaultNotificationPosition: NotificationPosition = 'top-center';
const notificationMessages = {
  successToast: (responseData: any) => ({
    title: 'Operación exitosa',
    message: responseData.message || 'Salarios actualizados correctamente',
    color: 'green',
    position: defaultNotificationPosition,
  }),
  errorToast: (error: any) => ({
    title: 'Error al asignar salario',
    message: error.response?.data?.message || 'Ocurrió un error inesperado',
    color: 'red',
    position: defaultNotificationPosition,
  }),
  invalidFields: {
    title: 'Error al asignar salario',
    message: 'Debe ingresar ambos campos',
    color: 'red',
    position: defaultNotificationPosition,
  },
};

export function AssignUsersPage() {
  const [departments, setDepartments] = useState<{ label: string; value: number }[]>([]);
  const [selectedDepartment, setSelectedDepartment] = useState<{
    label: string;
    value: number;
  } | null>(null);
  const [IDCard, setIDCard] = useState<number>(0);
  const [IDCards, setIDCards] = useState<number[]>([]);
  const { successToast, errorToast, invalidFields } = notificationMessages;

  useEffect(() => {
    getDepartments().then((departmentsData) => {
      const formattedDepartments = departmentsData.map((dep: any) => ({
        label: dep.depnombre,
        value: dep.departamentoid,
      }));
      setDepartments(formattedDepartments);
    });
  }, []);

  // function handleAssignSalary() {
  //   {
  //     console.log('Assigning salary:', selectedDepartment, salary);
  //     const params: any = {};
  //     if (selectedDepartment && salary) {
  //       params.departamentoId = selectedDepartment.value;
  //       params.salario = salary;
  //       // Call the function to assign the salary
  //       assignDepartmentSalary(params)
  //         .then((responseData) => {
  //           // Display a success notification with the response body
  //           notifications.show(successToast(responseData));
  //         })
  //         .catch((error) => {
  //           // Handle and show error notification
  //           notifications.show(errorToast(error));
  //           console.error('Error assigning salary:', error);
  //         });
  //     } else {
  //       notifications.show(invalidFields);
  //     }
  //   }
  // }

  function handleAddCollaborator() {
    if (IDCard) {
      setIDCards([...IDCards, IDCard]);
    }
  }

  return (
    <div className={classes.mainLayout}>
      <header className={classes.header}>
        <h1>Asignar empleados a departamento</h1>
        <p>
          Seleccione el departamento e ingrese las cédulas de los colaboradores por agregar al
          deparamento.
        </p>
      </header>
      <main className={classes.main}>
        <div className={classes.inputsContainer}>
          <SearchableSelect
            items={departments}
            selectedItem={selectedDepartment}
            setSelectedItem={setSelectedDepartment}
            placeholder="Seleccione un departamento"
            label="Departamento"
          />
          <NumberInput
            value={IDCard} // Bound to salary state
            onChange={(value) => {
              if (typeof value === 'number') {
                setIDCard(value);
              }
            }} // Update salary state on change
            placeholder="Ingrese la cédula del colaborador"
            label="Cédula"
          />
          <Button>
            <IconPlus />
          </Button>
        </div>
      </main>
      <footer className={classes.footer}></footer>
    </div>
  );
}

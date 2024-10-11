;
// React
import { useEffect, useState } from 'react';
// API
import { assignDepartmentSalary, getDepartments } from '@api';
// Components
import { SearchableSelect } from '@components';
import { Button, Flex, NumberInput } from '@mantine/core';
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
    message: 'Debe ingresar el departamento',
    color: 'red',
    position: defaultNotificationPosition,
  },
  invalidPercentage: {
    title: 'Error al asignar salario',
    message: 'El porcentaje debe ser mayor a 0 y menor que 5',
    color: 'red',
    position: defaultNotificationPosition,
  },
};

export function AssignDepartmentSalaryPage() {
  const [departments, setDepartments] = useState<{ label: string; value: number }[]>([]);
  const [selectedDepartment, setSelectedDepartment] = useState<{
    label: string;
    value: number;
  } | null>(null);
  const [salary, setSalary] = useState<number | string>('');
  const [children, setChildren] = useState<number | string>('');
  const [spouse, setSpouse] = useState<boolean | null>(null);
  const [percentage, setPercentage] = useState<number | string>('');
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

  const handleSpouseChange = (event: any) => {
    const val = event.target.value;
    // Map string values to corresponding boolean or null
    if (val == 'true') setSpouse(true);
    else if (val == 'false') setSpouse(false);
    else setSpouse(null); // For 'null' or when nothing is selected
  };

  function handleAssignSalary() {
    {
      console.log('Assigning salary:', selectedDepartment, salary);
      const params: any = {};
      if (selectedDepartment) {
        params.departmentID = selectedDepartment.value;
        if (salary) {
          params.salary = salary;
        }
        if (children) {
          params.children = children;
        }
        if (spouse !== null) {
          params.spouse = spouse;
        }
        if (percentage !== '') {
          const numericPercentage = Number(percentage); // Convert to number

          // Check if the conversion was successful and perform the comparison
          if (isNaN(numericPercentage) || numericPercentage < 0 || numericPercentage > 5) {
            notifications.show(notificationMessages.invalidPercentage);
            return;
          }

          // If the percentage is valid, continue with your logic
          params.percentage = numericPercentage; // Use the numeric value
        }

        // Call the function to assign the salary
        assignDepartmentSalary(params)
          .then((responseData) => {
            // Display a success notification with the response body
            notifications.show(successToast(responseData));
          })
          .catch((error) => {
            // Handle and show error notification
            notifications.show(errorToast(error));
            console.error('Error assigning salary:', error);
          });
      } else {
        notifications.show(invalidFields);
      }
    }
  }
  return (
    <div className={classes.mainLayout}>
      <header className={classes.header}></header>
      <main className={classes.main}>
        <Flex wrap={'wrap'} gap={'md'}>
          <SearchableSelect
            items={departments}
            selectedItem={selectedDepartment}
            setSelectedItem={setSelectedDepartment}
            placeholder="Seleccione un departamento"
            label="Departamento"
          />
          <NumberInput
            style={{ width: '250px' }}
            value={salary} // Bound to salary state
            onChange={(value) => setSalary(value)} // Update salary state on change
            placeholder="Ingrese el salario"
            label="Salario"
          />
          <Button onClick={handleAssignSalary}>Asignar</Button>
        </Flex>
      </main>
      <footer className={classes.footer}></footer>
    </div>
  );
}
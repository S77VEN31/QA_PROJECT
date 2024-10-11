import { useEffect, useState } from 'react';
// API
import { getDepartments } from '@api';
// Components
import { SearchableSelect } from '@components';
// Icons
// Mantine
import { Button, NumberInput, Text, Title } from '@mantine/core';
import { useForm } from '@mantine/form';
import { notifications } from '@mantine/notifications';
// Classes
import classes from './SetUser.module.css';

const defaultNotificationPosition = 'top-center';
const notificationMessages = {
  successToast: (responseData: any) => ({
    title: 'Operación exitosa',
    message: responseData.message || 'Colaboradores asignados correctamente',
    color: 'green',
    position: defaultNotificationPosition,
  }),
  errorToast: (error: any) => ({
    title: 'Error al asignar colaboradores',
    message: error.response?.data?.message || 'Ocurrió un error inesperado',
    color: 'red',
    position: defaultNotificationPosition,
  }),
  invalidFields: {
    title: 'Error al asignar colaboradores',
    message: 'Debe seleccionar un departamento y agregar al menos una cédula',
    color: 'red',
    position: defaultNotificationPosition,
  },
  duplicateIDCard: {
    title: 'Error',
    message: 'La cédula ya ha sido agregada',
    color: 'red',
    position: defaultNotificationPosition,
  },
};

export function SetUserPage() {
  const [departments, setDepartments] = useState<{ label: string; value: number }[]>([]);

  // Inicializa el formulario
  const form = useForm({
    initialValues: {
      selectedDepartment: null,
      IDCard: '',
    },
    validate: {
      selectedDepartment: (value) => (value ? null : 'Debe seleccionar un departamento'),
      IDCard: (value) => (value ? null : 'Debe ingresar una cédula válida'),
    },
  });

  useEffect(() => {
    getDepartments().then((departmentsData) => {
      const formattedDepartments = departmentsData.map((dep: any) => ({
        label: dep.depnombre,
        value: dep.departamentoid,
      }));
      setDepartments(formattedDepartments);
    });
  }, []);

  function handleAddCollaborator() {
    const { IDCard, IDCards } = form.values;
    const numericIDCard = Number(IDCard);

    if (!IDCard || IDCards.includes(numericIDCard)) {
      notifications.show(notificationMessages.duplicateIDCard);
    } else {
      form.setFieldValue('IDCards', [...IDCards, numericIDCard]);
      form.setFieldValue('IDCard', ''); // Limpiar campo de cédula
    }
  }

  function handleSubmit() {
    const { selectedDepartment, IDCards } = form.values;

    if (selectedDepartment && IDCards.length > 0) {
      const params = {
        departmentId: selectedDepartment.value,
        idCards: IDCards,
      };

      // Lógica de envío de datos (asigna colaboradores al departamento)
      // Aquí podrías hacer una llamada a una API con los datos recolectados
      console.log('Enviando datos:', params);

      notifications.show(notificationMessages.successToast({}));
    } else {
      notifications.show(notificationMessages.invalidFields);
    }
  }

  return (
    <div className={classes.mainLayout}>
      <header className={classes.header}>
        <Title>Asignar empleados a departamento</Title>
        <Text>
          Seleccione el departamento e ingrese las cédulas de los colaboradores por agregar al
          departamento.
        </Text>
      </header>
      <main className={classes.main}>
        <form onSubmit={form.onSubmit(handleSubmit)} className={classes.form}>
          <div className={classes.inputsContainer}>
            <SearchableSelect
              items={departments}
              selectedItem={form.values.selectedDepartment}
              setSelectedItem={(item) => form.setFieldValue('selectedDepartment', item)}
              placeholder="Seleccione un departamento"
              label="Departamento"
            />
            <NumberInput
              hideControls
              className={classes.input}
              {...form.getInputProps('IDCard')}
              placeholder="Ingrese la cédula del colaborador"
              label="Cédula"
              required
            />
          </div>
          <div className={classes.buttonContainer}>
            <Button type="submit">Asignar colaboradores</Button>
          </div>
        </form>
      </main>
    </div>
  );
}

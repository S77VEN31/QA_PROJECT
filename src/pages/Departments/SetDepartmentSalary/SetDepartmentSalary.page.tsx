// React
import { useEffect, useState } from 'react';
// API
import { getDepartments, setDepartmentSalary, SetSalaryParams } from '@api';
// Components
import { SearchableSelect } from '@components';
// Mantine
import { Button, NumberInput, Switch, Text, Title } from '@mantine/core';
import { useForm } from '@mantine/form';
import { notifications } from '@mantine/notifications';
import { NotificationPosition } from '@mantine/notifications/lib/notifications.store';
// Classes
import classes from './SetDepartmentSalary.page.module.css';

const defaultNotificationPosition: NotificationPosition = 'top-center';

const notificationMessages = {
  successToast: (responseData: any, updatedValues: string) => ({
    title: 'Operación exitosa',
    message: responseData.message + updatedValues || 'Salarios actualizados correctamente',
    color: 'green',
    position: defaultNotificationPosition,
    autoClose: 8000,
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
  emptyFields: {
    title: 'Error al asignar salario',
    message: 'Debe ingresar al menos un campo',
    color: 'red',
    position: defaultNotificationPosition,
  },
};

export function SetDepartmentSalaryPage() {
  const [departments, setDepartments] = useState<{ label: string; value: number }[]>([]);
  const [selectedDepartment, setSelectedDepartment] = useState<{
    label: string;
    value: number;
  } | null>(null);
  const form = useForm({
    initialValues: {
      departmentID: undefined,
      salary: undefined,
      childrenQuantity: undefined,
      hasSpouse: undefined,
      contributionPercentage: undefined,
    } as SetSalaryParams,
    validate: {
      salary: (value) => {
        if (value === undefined || (typeof value === 'string' && value === '')) {
          return null; // Allow empty value
        }
        const numericSalary = Number(value);
        return numericSalary > 0 ? null : 'El salario si se ingresó debe ser mayor a 0';
      },
      contributionPercentage: (value) => {
        if (value === undefined || (typeof value === 'string' && value === '')) {
          return null; // Allow empty value
        }
        const numericPercentage = Number(value);
        return numericPercentage >= 0 && numericPercentage <= 5
          ? null
          : 'El porcentaje debe ser mayor o igual a 0 y menor o igual a 5';
      },
      childrenQuantity: (value) => {
        if (value === undefined || (typeof value === 'string' && value === '')) {
          return null; // Allow empty value
        }
        const numericChildren = Number(value);
        return numericChildren >= 0 ? null : 'El número de hijos debe ser mayor o igual a 0';
      },
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

  const handleAssignSalary = (values: SetSalaryParams) => {
    if (!values.departmentID) {
      notifications.show(notificationMessages.invalidFields);
      return;
    }

    if (
      !values.salary &&
      !values.childrenQuantity &&
      values.hasSpouse === undefined &&
      !values.contributionPercentage
    ) {
      notifications.show(notificationMessages.emptyFields);
      return;
    }

    setDepartmentSalary(values)
      .then((responseData) => {
        let updatedValues = '. Se actualizó:';
        if (values.salary) {
          updatedValues += ` Salario: ${values.salary}.`;
        }
        if (values.childrenQuantity) {
          updatedValues += ` Número de hijos: ${values.childrenQuantity}.`;
        }
        if (values.hasSpouse !== undefined) {
          updatedValues += ` Tiene cónyuge: ${values.hasSpouse ? 'Sí' : 'No'}.`;
        }
        if (values.contributionPercentage) {
          updatedValues += `  Porcentaje de aporte: ${values.contributionPercentage}%.`;
        }
        notifications.show(notificationMessages.successToast(responseData, updatedValues));
        form.reset();
        setSelectedDepartment(null);
      })
      .catch((error) => {
        notifications.show(notificationMessages.errorToast(error));
      });
  };

  useEffect(() => {
    if (selectedDepartment) {
      form.setFieldValue('departmentID', selectedDepartment.value);
    }
  }, [selectedDepartment]);

  useEffect(() => {
    console.log(form.values);
  }, [form.values]);

  return (
    <div className={classes.mainLayout}>
      <header className={classes.header}>
        <Title>Asignar salario a departamento</Title>
        <Text>
          Seleccione un departamento y asigne los valores a modificar: salario, número de hijos,
          porcentaje de aporte a la asociación solidarista y cónyuge. Deje en blanco los campos que
          desea que se mantengan con su valor anterior.
        </Text>
      </header>
      <main className={classes.main}>
        <form onSubmit={form.onSubmit(handleAssignSalary)} className={classes.formContainer}>
          <div className={classes.inputsContainer}>
            <SearchableSelect
              required
              items={departments}
              selectedItem={selectedDepartment}
              setSelectedItem={setSelectedDepartment}
              placeholder="Seleccione un departamento"
              label="Departamento"
              aria-label="Seleccione un departamento"
            />
            <NumberInput
              hideControls
              className={classes.input}
              {...form.getInputProps('salary')}
              value={form.values.salary || ''}
              onChange={(value) =>
                value === ''
                  ? form.setFieldValue('salary', undefined)
                  : form.setFieldValue('salary', value as number)
              }
              placeholder="Ingrese el salario"
              label="Salario"
              aria-label="Ingrese el salario"
              allowDecimal={false}
              allowNegative={false}
            />
          </div>
          <div className={classes.inputsContainer}>
            <NumberInput
              className={classes.input}
              {...form.getInputProps('childrenQuantity')}
              value={form.values.childrenQuantity !== undefined ? form.values.childrenQuantity : ''}
              onChange={(value) =>
                value === ''
                  ? form.setFieldValue('childrenQuantity', undefined)
                  : form.setFieldValue('childrenQuantity', value as number)
              }
              placeholder="Ingrese el número de hijos"
              label="Número de hijos"
              aria-label="Ingrese el número de hijos"
              allowDecimal={false}
              allowNegative={false}
            />
            <NumberInput
              hideControls
              className={classes.input}
              {...form.getInputProps('contributionPercentage')}
              value={
                form.values.contributionPercentage !== undefined
                  ? form.values.contributionPercentage
                  : ''
              }
              onChange={(value) =>
                value === ''
                  ? form.setFieldValue('contributionPercentage', undefined)
                  : form.setFieldValue('contributionPercentage', value as number)
              }
              placeholder="Ingrese el porcentaje de aporte"
              label="Porcentaje de aporte a la Asociación Solidarista"
              aria-label="Ingrese el porcentaje de aporte a la Asociación Solidarista"
              allowDecimal
              allowNegative={false}
            />
          </div>
          <div className={classes.inputsContainer}>
            <Switch
              checked={form.values.hasSpouse}
              onChange={(event) => form.setFieldValue('hasSpouse', event.currentTarget.checked)}
              label="¿Tiene cónyuge?"
              aria-label="¿Tiene cónyuge?"
              className={classes.switch}
            />
          </div>
          <div className={classes.buttonContainer}>
            <Button type="submit">Asignar salario a un departamento</Button>
          </div>
        </form>
      </main>
    </div>
  );
}

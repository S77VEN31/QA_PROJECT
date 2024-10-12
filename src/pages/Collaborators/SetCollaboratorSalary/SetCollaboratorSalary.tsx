import { useEffect, useState } from 'react';
// API
import { getDepartments, getEmployeeSalary, setEmployeeSalary, SetSalaryParams } from '@api';
// Components
import { SearchableSelect } from '@components';
import { useSearchParams } from 'react-router-dom';
// Mantine
import { Button, NumberInput, Switch, Text, TextInput, Title } from '@mantine/core';
import { useForm } from '@mantine/form';
import { notifications } from '@mantine/notifications';
import { NotificationPosition } from '@mantine/notifications/lib/notifications.store';
// Classes
import classes from './SetCollaboratorSalary.module.css';

const defaultNotificationPosition: NotificationPosition = 'top-center';

const notificationMessages = {
  successToast: (responseData: any) => ({
    title: 'Operación exitosa',
    message: responseData.message || 'Salario asignado correctamente',
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
    message: 'Debe ingresar la cédula y el departamento',
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

export function SetCollaboratorSalaryPage() {
  const [searchParams] = useSearchParams();
  const [departments, setDepartments] = useState<{ label: string; value: number }[]>([]);
  const [selectedDepartment, setSelectedDepartment] = useState<{
    label: string;
    value: number;
  } | null>(null);
  const [cardID, setCardID] = useState<string | undefined>(undefined);
  const form = useForm({
    initialValues: {
      cardID: undefined,
      departmentID: undefined,
      salary: undefined,
      childrenQuantity: undefined,
      hasSpouse: false,
      contributionPercentage: undefined,
    } as SetSalaryParams,
    validate: {
      cardID: (value: string) => {
        return value && value.length === 9 ? null : 'La cédula es requerida y debe tener 9 dígitos';
      },
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

  const fetchDepartments = (cardID: string | undefined) => {
    getDepartments(cardID).then((departmentsData) => {
      const formattedDepartments = departmentsData.map((dep: any) => ({
        label: dep.depnombre,
        value: dep.departamentoid,
      }));
      setDepartments(formattedDepartments);
      if (formattedDepartments.length === 1) {
        setSelectedDepartment(formattedDepartments[0]);
      } else {
        setSelectedDepartment(null);
      }
    });
  };

  const fetchEmployeeSalary = async (cardID: string, departmentID: number) => {
    try {
      const employeeSalary = await getEmployeeSalary(cardID, departmentID);
      const { salary, childrenquantity, hasspouse, contributionpercentage } = employeeSalary;

      form.setValues({
        salary,
        childrenQuantity: childrenquantity,
        hasSpouse: hasspouse,
        contributionPercentage: contributionpercentage,
      });
    } catch (error) {
      notifications.show(notificationMessages.errorToast(error));
    }
  };

  useEffect(() => {
    const cardIDquery = searchParams.get('cardID');
    console.log('cardIDquery:', cardIDquery);
    if (cardIDquery) {
      form.setFieldValue('cardID', cardIDquery);
      setCardID(cardIDquery);
    }
  }, [searchParams]);

  useEffect(() => {
    if (cardID) {
      fetchDepartments(cardID);
    } else {
      setDepartments([]);
      setSelectedDepartment(null);
    }
  }, [cardID]);

  useEffect(() => {
    if (cardID && selectedDepartment) {
      fetchEmployeeSalary(cardID, selectedDepartment.value);
    }
  }, [cardID, selectedDepartment]);

  const handleAssignSalary = (values: SetSalaryParams) => {
    if (!values.cardID || !values.departmentID) {
      notifications.show(notificationMessages.invalidFields);
      return;
    }

    setEmployeeSalary(values, values.cardID)
      .then((responseData) => {
        notifications.show(notificationMessages.successToast(responseData));
        form.reset();
        setCardID('');
        setSelectedDepartment(null);
      })
      .catch((error) => {
        notifications.show(notificationMessages.errorToast(error));
      });
  };

  const handleHasSpouseChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    form.setFieldValue('hasSpouse', event.currentTarget.checked);
  };

  useEffect(() => {
    if (selectedDepartment) {
      form.setFieldValue('departmentID', selectedDepartment.value);
    } else {
      form.setFieldValue('departmentID', undefined);
    }
  }, [selectedDepartment]);

  useEffect(() => {
    console.log(form.values);
  }, [form.values]);

  return (
    <div className={classes.mainLayout}>
      <header className={classes.header}>
        <Title>Asignar salario a colaborador</Title>
        <Text>Seleccione un departamento y asigne un salario a un colaborador.</Text>
      </header>
      <main className={classes.main}>
        <form onSubmit={form.onSubmit(handleAssignSalary)} className={classes.formContainer}>
          <div className={classes.inputsContainer}>
            <TextInput
              type="number"
              required
              className={classes.input}
              value={form.values.cardID || ''}
              onChange={(e) => {
                if (e.target.value.length <= 9) {
                  form.setFieldValue('cardID', e.target.value);
                  setCardID(e.target.value);
                }
              }}
              placeholder="Ingrese la cédula"
              label="Cédula del colaborador"
              aria-label="Ingrese la cédula"
            />
            <SearchableSelect
              required
              items={departments}
              selectedItem={selectedDepartment}
              setSelectedItem={setSelectedDepartment}
              placeholder={
                selectedDepartment ? selectedDepartment.label : 'Seleccione un departamento'
              }
              label="Departamento"
              aria-label="Seleccione un departamento"
            />
          </div>
          <div className={classes.inputsContainer}>
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
            <Switch
              checked={form.values.hasSpouse}
              onChange={handleHasSpouseChange}
              label="¿Tiene cónyuge?"
              aria-label="¿Tiene cónyuge?"
              className={classes.switch}
            />
          </div>
          <div className={classes.buttonContainer}>
            <Button type="submit">Asignar salario al colaborador</Button>
          </div>
        </form>
      </main>
    </div>
  );
}

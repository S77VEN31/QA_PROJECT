import { useEffect, useState } from 'react';
// API
import { getDepartments, AssignCollaboratorsParams, assignCollaborators, getCollaboratorName } from '@api';
// Components
import { SearchableSelect } from '@components';
// Mantine
import { Button, NumberInput, Table, Text, Title } from '@mantine/core';
import { useForm } from '@mantine/form';
import { notifications } from '@mantine/notifications';
import { NotificationPosition } from '@mantine/notifications/lib/notifications.store';
// Classes
import classes from './AssignCollaborators.module.css';

interface EmpleadoNombreData {
  getempleadonombre: string;
}

const defaultNotificationPosition: NotificationPosition = 'top-center';

const notificationMessages = {
  successToast: (responseData: any) => ({
    title: 'Operación exitosa',
    message: responseData.message || 'Colaboradores asignados correctamente',
    color: 'green',
    position: defaultNotificationPosition,
  }),
  errorToast: (error: any) => ({
    title: 'Error al añadir colaboradores',
    message: error.response?.data?.message || 'Ocurrió un error inesperado',
    color: 'red',
    position: defaultNotificationPosition,
  }),
  cardIDExists: {
    title: 'Error al añadir colaborador',
    message: 'La cédula ya está en la lista',
    color: 'red',
    position: defaultNotificationPosition,
  },
  invalidCardID: {
    title: 'Error al añadir colaborador',
    message: 'La cédula debe tener 9 dígitos y ser un número válido',
    color: 'red',
    position: defaultNotificationPosition,
  },
  invalidFields: {
    title: 'Error al añadir colaboradores',
    message: 'Complete los campos requeridos',
    color: 'red',
    position: defaultNotificationPosition,
  },
  noCollaborators: {
    title: 'Error al añadir colaboradores',
    message: 'Debe añadir al menos un colaborador',
    color: 'red',
    position: defaultNotificationPosition,
  },
  invalidDepartment: {
    title: 'Error al añadir colaboradores',
    message: 'El departamento es inválido.',
    color: 'red',
    position: defaultNotificationPosition,
  },
};

export function AssignCollaboratorsPage() {
  const [departments, setDepartments] = useState<{ label: string; value: number }[]>([]);
  const [selectedDepartment, setSelectedDepartment] = useState<{
    label: string;
    value: number;
  } | null>(null);
  const [cardIDs, setCardIDs] = useState<number[]>([]); // Using cardIDs instead of items
  const [newCardID, setNewCardID] = useState<number>(0);
  const [collaboratorMap, setCollaboratorMap] = useState<{ [key: number]: string }>({}); // Map for cardID -> Name

  useEffect(() => {
    getDepartments().then((departmentsData) => {
      const formattedDepartments = departmentsData.map((dep: any) => ({
        label: dep.depnombre,
        value: dep.departamentoid,
      }));
      setDepartments(formattedDepartments);
    });
  }, []);

  const deleteCardID = (index: number) => {
    const updatedCardIDs = cardIDs.filter((_, i) => i !== index);
    const removedCardID = cardIDs[index]; 
    setCardIDs(updatedCardIDs);
    form.setFieldValue('cardIDs', updatedCardIDs); // Update the form's cardIDs
    
    // Remove the cardID from the collaboratorMap
    setCollaboratorMap((prevMap) => {
      const newMap = { ...prevMap };
      delete newMap[removedCardID];
      return newMap;
    });
  };

  const addCardID = () => {
    if (newCardID > 99999999) { // Ensure the cardID is valid (9 digits)
      if (cardIDs.includes(newCardID)) {
        notifications.show(notificationMessages.cardIDExists);
      } else {
        getCollaboratorName(newCardID)
          .then((collaboratorName: EmpleadoNombreData) => {
            if (!collaboratorName) {
              notifications.show(notificationMessages.errorToast({ message: 'Colaborador no encontrado' }));
              return;
            }
            // Add new cardID and corresponding name to the map
            setCollaboratorMap((prevMap) => ({
              ...prevMap,
              [newCardID]: collaboratorName.getempleadonombre,
            }));
            const updatedCardIDs = [...cardIDs, newCardID];
            setCardIDs(updatedCardIDs); // Update local state
            form.setFieldValue('cardIDs', updatedCardIDs); // Update the form's cardIDs
            setNewCardID(0); // Clear the input after adding
            })
          .catch((error) => {
            notifications.show(notificationMessages.errorToast(error));
          });
      }
    } else {
      notifications.show(notificationMessages.invalidCardID);
    }
  };

  // Form definition with initial values and validation
  const form = useForm({
    initialValues: {
      departmentID: -1,
      cardIDs: [],
    } as AssignCollaboratorsParams,
    validate: {
      cardIDs: (value: Array<number>) => {
        console.log(value);
        if (!value || value.length === 0) {
          notifications.show(notificationMessages.noCollaborators);
          return 'Debe añadir al menos un colaborador.';
        }
        if (value.every((cardID) => cardID.toString().length === 9 && isNaN(cardID))) {
          notifications.show(notificationMessages.invalidCardID);
          return 'Cada cédula debe tener 9 dígitos y ser un número válido.';
        } else {
          return null
        }
      },
      departmentID: (value) => {
        if (value === undefined || value === null || value === -1) {
          notifications.show(notificationMessages.invalidDepartment);
          return 'El departamento es requerido.';
        }
        if (value > 0) {
          return null;
        } else {
          notifications.show(notificationMessages.invalidDepartment);
          return 'El departamento debe ser un número válido.';
        }
      },
    },
  });

  // Update the form's departmentID when the department is selected
  useEffect(() => {
    if (selectedDepartment) {
      form.setFieldValue('departmentID', selectedDepartment.value);
    } else {
      form.setFieldValue('departmentID',  -1);
    }
  }, [selectedDepartment]);


  const handleAssignCollaborators = (values: AssignCollaboratorsParams) => {    
    if (values.cardIDs.length === 0 || !values.departmentID) {
      notifications.show(notificationMessages.invalidFields);
      return;
    }
    console.log(values);

    assignCollaborators(values)
      .then(() => {
        notifications.show(notificationMessages.successToast({ message: 'Colaboradores asignados correctamente.'}));
        form.reset(); // Reset the form after successful submission
        setCardIDs([]); // Clear cardIDs after submitting
        setCollaboratorMap({}); // Clear the map after submitting
        setSelectedDepartment(null); // Clear department selection
      })
      .catch((error) => {
        notifications.show(notificationMessages.errorToast(error));
      });
  };

  return (
    <div className={classes.mainLayout}>
      <header className={classes.header}>
        <Title>Añadir colaboradores a departamento</Title>
        <Text>Seleccione un departamento e ingrese las cédulas de los empleados. Escriba la cédula de uno y luego presione el botón de añadir. Cuando ya están todos los empleados, presione el botón de asignar.</Text>
      </header>
      <main className={classes.main}>
        <form onSubmit={form.onSubmit(handleAssignCollaborators)} className={classes.formContainer}>
          <div className={classes.inputsContainer}>
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
            <NumberInput
              max = {999999999}
              clampBehavior='strict'
              allowDecimal={false}
              className={classes.input}
              value={newCardID}
              onChange={(value) => setNewCardID(typeof value === 'number' ? value : 0)}
              placeholder="Ingrese la cédula"
              label="Cédula del colaborador"
              aria-label="Ingrese la cédula"
            />
            <Button onClick={addCardID} type="button">Agregar cédula</Button>
          </div>
          <div className={classes.tableContainer}>
            <Table>
              <Table.Caption> Colaboradores por añadir </Table.Caption>
              <Table.Thead>
                <Table.Tr>
                  <Table.Th scope="col">Cédula</Table.Th>
                  <Table.Th scope="col">Nombre</Table.Th>
                  <Table.Th scope="col">Eliminar</Table.Th>
                </Table.Tr>
              </Table.Thead>
              <Table.Tbody>
                {cardIDs.map((cardID, index) => (
                  <Table.Tr key={index}>
                    <Table.Td>
                      {cardID}
                    </Table.Td>
                    <Table.Td>{collaboratorMap[cardID]}</Table.Td> 
                    <Table.Td>
                    <Button
                      color="red" // Sets the button's background color to red
                      variant="filled" // Makes the button filled with color (no outline)
                      onClick={() => deleteCardID(index)}
                      styles={(theme) => ({
                        root: {
                          color: 'white', // Ensures the text is white
                        },
                      })}
                    >
                      X
                    </Button>
                    </Table.Td>
                  </Table.Tr>
                ))}
              </Table.Tbody>
              </Table>  
              <Button type="submit">Añadir colaboradores</Button>
          </div>
        </form>
      </main>
    </div>
  );
}
// React
import { useState } from 'react';
// API
import { login } from '@api';
// Components
import { ColorSchemeToggle } from '@components';
// React Router
import { useNavigate } from 'react-router-dom';
// Mantine
import { Anchor, Button, Group, Paper, PasswordInput, Text, TextInput, Title } from '@mantine/core';
import { useForm } from '@mantine/form';
// Classes
import classes from './Login.page.module.css';

export function LoginPage() {
  const navigate = useNavigate();
  const [error, setError] = useState('');

  const form = useForm({
    initialValues: {
      email: '',
      password: '',
    },
    validate: {
      email: (value) => (/^\S+@\S+$/.test(value) ? null : 'Correo electrónico inválido'),
      password: (value) => (value && value.trim() ? null : 'La contraseña no puede estar vacía'),
    },
  });

  const handleSubmit = async (values: { email: string; password: string }) => {
    try {
      setError('');
      await login({
        email: values.email,
        password: values.password,
      });
      navigate('/dashboard/report/detailed');
    } catch (error) {
      setError('Correo electrónico o contraseña inválidos.');
    }
  };

  return (
    <div className={classes.mainLayout}>
      <div className={classes.contentWrapper} role="presentation">
        <header className={classes.header}>
          <Title className={classes.title}>Bienvenido a NóminaPro</Title>
          <Text c="dimmed" size="lg" mt={10} className={classes.description}>
            Ingrese su correo electrónico y contraseña para iniciar sesión.
          </Text>
        </header>
        <main className={classes.main}>
          <section className={classes.container}>
            <h2 className={classes.visuallyHidden}>Formulario de inicio de sesión</h2>
            <Paper withBorder shadow="md" radius="md" className={classes.paper}>
              <form
                className={classes.form}
                onSubmit={form.onSubmit(handleSubmit)}
                id="login-form"
                aria-describedby={error ? 'login-form-error' : undefined}
              >
                <TextInput
                  {...form.getInputProps('email')}
                  id="email-input"
                  label="Correo electrónico"
                  placeholder="micorreo@tec.cr"
                  aria-invalid={!!form.errors.email}
                  error={form.errors.email}
                  errorProps={{ id: 'email-error', role: 'alert' }}
                />
                <PasswordInput
                  {...form.getInputProps('password')}
                  id="password-input"
                  label="Contraseña"
                  placeholder="Mi contraseña super segura"
                  aria-invalid={!!form.errors.password}
                  error={form.errors.password}
                  errorProps={{ id: 'password-error', role: 'alert' }}
                />
                <Group justify="flex-end" mb={5} mt="md">
                  <Anchor
                    href="#"
                    onClick={(event) => event.preventDefault()}
                    pt={2}
                    fw={500}
                    fz="xs"
                  >
                    ¿Olvidó su contraseña?
                  </Anchor>
                </Group>
                <Button type="submit" fullWidth mt="lg">
                  Iniciar sesión
                </Button>
                {error && (
                  <Text role="alert" id="login-form-error" color="red" size="sm" mt="md">
                    {error}
                  </Text>
                )}
              </form>
            </Paper>
          </section>
        </main>
      </div>
      <footer className={classes.footer}>
        <ColorSchemeToggle />
      </footer>
    </div>
  );
}

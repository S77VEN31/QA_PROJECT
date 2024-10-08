// React
import { useState } from 'react';
// API
import { login } from '@api';
// Components
import { ColorSchemeToggle } from '@components';
import { useNavigate } from 'react-router-dom';
// Mantine
import {
  Anchor,
  Button,
  Container,
  Group,
  Paper,
  PasswordInput,
  Text,
  TextInput,
  Title,
} from '@mantine/core';
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
      email: (value) => (/^\S+@\S+$/.test(value) ? null : 'Invalid email'),
      password: (value) => (value.length < 6 ? 'Password must be at least 6 characters' : null),
    },
  });

  const handleSubmit = async (values: any) => {
    try {
      await login({
        email: values.email,
        password: values.password,
      });
      navigate('/dashboard/report/detailed');
    } catch (error) {
      setError('Invalid email or password');
    }
  };

  return (
    <div className={classes.mainLayout}>
      <div className={classes.contentWrapper}>
        <header className={classes.header}>
          <Title className={classes.title}>Welcome back!</Title>
          <Text c="dimmed" size="lg" mt={10} className={classes.description}>
            Enter your email and password to login
          </Text>
        </header>
        <main className={classes.main}>
          <Container size="xl" className={classes.container}>
            <Paper withBorder shadow="md" radius="md" className={classes.paper}>
              <form onSubmit={form.onSubmit(handleSubmit)}>
                <TextInput
                  label="Email"
                  placeholder="you@mantine.dev"
                  {...form.getInputProps('email')}
                />
                <Group justify="space-between" mb={5} mt="md">
                  <Text component="label" htmlFor="your-password" size="sm" fw={500}>
                    Your password
                  </Text>
                  <Anchor
                    href="#"
                    onClick={(event) => event.preventDefault()}
                    pt={2}
                    fw={500}
                    fz="xs"
                  >
                    Forgot your password?
                  </Anchor>
                </Group>
                <PasswordInput
                  placeholder="Your password"
                  id="your-password"
                  {...form.getInputProps('password')}
                />
                {error && (
                  <Text color="red" size="sm" mt="md">
                    {error}
                  </Text>
                )}
                <Button type="submit" fullWidth mt="lg">
                  Login
                </Button>
              </form>
            </Paper>
          </Container>
        </main>
      </div>
      <footer className={classes.footer}>
        <ColorSchemeToggle />
      </footer>
    </div>
  );
}

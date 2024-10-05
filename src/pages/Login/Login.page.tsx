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
import { ColorSchemeToggle } from '@/components/ColorSchemeToggle/ColorSchemeToggle';
import styles from './Login.page.module.css';

export function LoginPage() {
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

  return (
    <div className={styles.mainLayout}>
      <div className={styles.contentWrapper}>
        <header className={styles.header}>
          <Title className={styles.title}>Welcome back!</Title>
          <Text c="dimmed" size="lg" mt={10} className={styles.description}>
            Enter your email and password to login
          </Text>
        </header>
        <main className={styles.main}>
          <Container size="xl" className={styles.container}>
            <Paper withBorder shadow="md" radius="md" className={styles.paper}>
              <form onSubmit={form.onSubmit((values) => console.log(values))}>
                <TextInput
                  label="Email"
                  placeholder="you@mantine.dev"
                  {...form.getInputProps('email')}
                />

                {/* Forgot Password Input */}
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
                  {...form.getInputProps('password')} // Conectamos con useForm
                />

                <Button type="submit" fullWidth mt="lg">
                  Login
                </Button>
              </form>
            </Paper>
          </Container>
        </main>
      </div>
      <footer className={styles.footer}>
        <ColorSchemeToggle />
      </footer>
    </div>
  );
}

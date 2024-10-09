import { MantineProvider } from '@mantine/core';

import '@mantine/core/styles.css';

import { setupInterceptors } from '@api';
import { Notifications } from '@mantine/notifications';
import { Router } from './Router';
import { theme } from './theme';

import '@mantine/notifications/styles.css';

import { useEffect } from 'react';

export default function App() {
  useEffect(() => {
    setupInterceptors();
  }, []);
  return (
    <MantineProvider theme={theme}>
      <Notifications />
      <Router />
    </MantineProvider>
  );
}

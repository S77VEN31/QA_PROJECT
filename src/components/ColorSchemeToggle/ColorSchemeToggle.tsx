import { IconDeviceDesktop, IconMoonStars, IconSun } from '@tabler/icons-react';
import { Button, Group, useMantineColorScheme } from '@mantine/core';
import classes from './ColorSchemeToggle.module.css';

export function ColorSchemeToggle() {
  const { setColorScheme } = useMantineColorScheme();

  return (
    <Group justify="center" mt="xl" className={classes.footer}>
      <Button onClick={() => setColorScheme('light')} aria-label={'Activar modo claro'}>
        <IconSun size={18} />
      </Button>
      <Button onClick={() => setColorScheme('dark')} aria-label={'Activar modo oscuro'}>
        <IconMoonStars size={18} />
      </Button>
      <Button onClick={() => setColorScheme('auto')} aria-label={'Activar modo por defecto'}>
        <IconDeviceDesktop size={18} />
      </Button>
    </Group>
  );
}

import { ColorSchemeToggle } from '@components';
import {
  IconAdjustments,
  IconCalendarStats,
  IconGauge,
  IconNotes,
  IconPresentationAnalytics,
} from '@tabler/icons-react';
import { Code, Group, ScrollArea } from '@mantine/core';
import { LinksGroup } from './NavbarLinksGroup';
import classes from './NavbarNested.module.css';

const mockdata = [
  { label: 'Reportes', icon: IconGauge, link: '/dashboard/reports' },
  { label: 'Pagos', icon: IconGauge, link: '/dashboard/pagos' },
  {
    label: 'Planilla',
    icon: IconNotes,
    initiallyOpened: true,
    links: [
      { label: 'Historial', link: '/dashboard/planilla/historial' },
      { label: 'Calcular', link: '/dashboard/planilla/calcular' },
    ],
  },
  {
    label: 'Departamentos',
    icon: IconCalendarStats,
    links: [
      { label: 'Asignar Salario', link: '/dashboard/departamentos/asignarsalario' },
      { label: 'Consultar', link: '/dashboard/departamentos/consultar' },
    ],
  },
  { label: 'Colaboradores', icon: IconPresentationAnalytics, link: '/dashboard/colaboradores' },
  { label: 'Configuración', icon: IconAdjustments, link: '/dashboard/configuracion' },
];

export function NavbarNested() {
  const links = mockdata.map((item) => <LinksGroup {...item} key={item.label} />);

  return (
    <nav className={classes.navbar}>
      <div className={classes.header}>
        <Group justify="space-between">
          <Code fw={700}>Evasion Fiscal TEC</Code>
        </Group>
      </div>
      <ScrollArea className={classes.links}>
        <div className={classes.linksInner}>{links}</div>
      </ScrollArea>
      <ColorSchemeToggle />
    </nav>
  );
}

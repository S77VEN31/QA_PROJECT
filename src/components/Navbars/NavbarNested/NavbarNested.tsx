import { ColorSchemeToggle } from '@components';
import { IconAdjustments, IconCalendarStats, IconGauge, IconPresentationAnalytics } from '@tabler/icons-react';
import { Code, Group, ScrollArea } from '@mantine/core';
import { LinksGroup } from './NavbarLinksGroup';
import classes from './NavbarNested.module.css';


const mockdata = [
  {
    label: 'Reportes',
    icon: IconGauge,
    links: [
      { label: 'Total', link: '/dashboard/report/total' },
      { label: 'Detallado', link: '/dashboard/report/detailed' },
    ],
  },
  { label: 'Pagos', icon: IconGauge, link: '/dashboard/pagos' },
  {
    label: 'Departamentos',
    icon: IconCalendarStats,
    links: [
      { label: 'Administrar', link: '/dashboard/departamentos/administrar' },
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
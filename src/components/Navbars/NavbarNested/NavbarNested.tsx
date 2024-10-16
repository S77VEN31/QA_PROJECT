;
// Components
import { ColorSchemeToggle } from '@components';
// Icons
import { IconBuilding, IconCash, IconFileReport, IconUsers } from '@tabler/icons-react';
// Mantine
import { Code, Group, ScrollArea } from '@mantine/core';
// Components
import { LinksGroup } from './NavbarLinksGroup';
// Classes
import classes from './NavbarNested.module.css';


const mockdata = [
  {
    label: 'Reportes',
    icon: IconFileReport,
    links: [
      { label: 'Total', link: '/dashboard/report/total' },
      { label: 'Detallado', link: '/dashboard/report/detailed' },
    ],
  },
  { label: 'Pagos', icon: IconCash, link: '/dashboard/pagos' },
  {
    label: 'Departamentos',
    icon: IconBuilding,
    links: [
      { label: 'Crear Departamento', link: '/dashboard/departments/create' },
      { label: 'Asignar Salario', link: '/dashboard/departments/assign-salary' },
      { label: 'Asignar Usuarios', link: '/dashboard/departments/assign-collaborators' },
      { label: 'Ver Totales', link: '/dashboard/departments/totals' },
      { label: 'Ver Empleados', link: '/dashboard/departments/employees' },
    ],
  },
  {
    label: 'Colaboradores',
    icon: IconUsers,
    links: [
      { label: 'Asignar Salario', link: '/dashboard/collaborators/assign-salary' },
      { label: 'Calculadora', link: '/dashboard/collaborators/calculator' },
    ],
  },
];

export function NavbarNested() {
  const links = mockdata.map((item) => <LinksGroup {...item} key={item.label} />);

  return (
    <nav className={classes.navbar}>
      <div className={classes.header}>
        <Group justify="space-between">
          <Code fw={700}>NóminaPro</Code>
        </Group>
      </div>
      <ScrollArea className={classes.links}>
        <div className={classes.linksInner}>{links}</div>
      </ScrollArea>
      <ColorSchemeToggle />
    </nav>
  );
}
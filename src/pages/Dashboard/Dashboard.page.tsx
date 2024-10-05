import { Outlet } from 'react-router-dom';
import { NavbarNested } from '@/components/Navbars/NavbarNested/NavbarNested';

export function DashboardPage() {
  return (
    <div
      style={{
        display: 'flex',
        flexDirection: 'row',
        flex: 1,
      }}
    >
      <NavbarNested />
      <Outlet />
    </div>
  );
}

import { NavbarNested } from '@components';
import { Outlet } from 'react-router-dom';

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

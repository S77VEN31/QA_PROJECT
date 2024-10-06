import { DashboardPage, HomePage, LoginPage, ReportsPage } from '@pages';
import { createBrowserRouter, RouterProvider } from 'react-router-dom';

const router = createBrowserRouter([
  {
    path: '/',
    element: <HomePage />,
  },
  {
    path: '/login',
    element: <LoginPage />,
  },
  {
    path: '/dashboard',
    element: <DashboardPage />,
    children: [
      {
        path: 'reports',
        element: <ReportsPage />,
      },
      {
        path: 'pagos',
        element: <div>Pagos page</div>,
      },
      {
        path: 'planilla/historial',
        element: <div>Historial page</div>,
      },
      {
        path: 'planilla/calcular',
        element: <div>Calcular page</div>,
      },
      {
        path: 'departamentos/administrar',
        element: <div>Administrar page</div>,
      },
      {
        path: 'departamentos/consultar',
        element: <div>Consultar page</div>,
      },
      {
        path: 'colaboradores',
        element: <div>Colaboradores page</div>,
      },
      {
        path: 'configuracion',
        element: <div>Configuración page</div>,
      },
    ],
  },
]);

export function Router() {
  return <RouterProvider router={router} />;
}

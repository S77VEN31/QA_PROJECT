import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import { DashboardPage } from './pages/Dashboard.page';
import { HomePage } from './pages/Home.page';

const router = createBrowserRouter([
  {
    path: '/',
    element: <HomePage />,
  },
  {
    path: '/login',
    element: <div>Login page</div>,
  },
  {
    path: '/dashboard',
    element: <DashboardPage />,
    children: [
      {
        path: 'events',
        element: <div>Events page</div>,
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
import {
  DashboardPage,
  DetailedReportPage,
  FortnightPage,
  HomePage,
  LoginPage,
  TotalReportPage,
  AssignDepartmentSalaryPage
} from '@pages';
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
        path: 'report/total',
        element: <TotalReportPage />,
      },
      {
        path: 'report/detailed',
        element: <DetailedReportPage />,
      },
      {
        path: 'pagos',
        element: <FortnightPage />,
      },
      {
        path: 'departamentos/asignarsalario',
        element: <AssignDepartmentSalaryPage />,
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

;
// API
import { getAuthToken } from '@api';
// Pages
import {
  CreateDepartmentPage,
  DashboardPage,
  DetailedReportPage,
  FortnightPage,
  LoginPage,
  SetEmployeeSalaryPage,
  SetSalaryPage,
  SetUserPage,
  TotalReportPage,
} from '@pages';
// Router
import { createBrowserRouter, Navigate, RouterProvider } from 'react-router-dom';

const ProtectedRoute = ({ element }: { element: JSX.Element }) => {
  const token = getAuthToken();
  if (!token) {
    return <Navigate to="/" replace />;
  }
  return element;
};

const router = createBrowserRouter([
  {
    path: '/',
    element: <LoginPage />,
  },
  {
    path: '/dashboard',
    element: <ProtectedRoute element={<DashboardPage />} />,
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
        path: 'departments/assign-salary',
        element: <SetSalaryPage />,
      },
      {
        path: 'departments/assign-users',
        element: <SetUserPage />,
      },
      {
        path: 'departments/create',
        element: <CreateDepartmentPage />,
      },
      {
        path: 'departments/assign-employee-salary',
        element: <SetEmployeeSalaryPage />,
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
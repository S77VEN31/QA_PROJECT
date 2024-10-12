// API
import { getAuthToken } from '@api';
// Pages
import {
  CalculatorPage,
  CreateDepartmentPage,
  DashboardPage,
  DepartmentEmployeesPage,
  DepartmentTotalsPage,
  DetailedReportPage,
  FortnightPage,
  LoginPage,
  SetCollaboratorSalaryPage,
  SetDepartmentSalaryPage,
  TotalReportPage,
  AssignCollaboratorsPage,
} from '@pages';
// Router
import { createBrowserRouter, Navigate, RouterProvider } from 'react-router-dom';

const ProtectedRoute = ({ element }: { element: JSX.Element }) => {
  const token = getAuthToken();
  if (!token) {
    console.log('REDIRECT');
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
        element: <SetDepartmentSalaryPage />,
      },
      {
        path: 'departments/assign-collaborators',
        element: <AssignCollaboratorsPage />,
      },
      {
        path: 'departments/create',
        element: <CreateDepartmentPage />,
      },
      {
        path: 'departments/totals',
        element: <DepartmentTotalsPage />,
      },
      {
        path: 'departments/employees',
        element: <DepartmentEmployeesPage />,
      },
      {
        path: 'collaborators/assign-salary',
        element: <SetCollaboratorSalaryPage />,
      },
      {
        path: 'collaborators/calculator',
        element: <CalculatorPage />,
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

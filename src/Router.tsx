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
  SetCollaboratorSalaryPage,
  SetDepartmentSalaryPage,
  SetUserPage,
  TotalReportPage,
  AssignCollaboratorsPage,
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
        path: 'collaborators/assign-salary',
        element: <SetCollaboratorSalaryPage />,
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
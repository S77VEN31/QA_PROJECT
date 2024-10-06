// Mantine
import { Pagination } from '@mantine/core';

interface ElipticPaginationProps {
  totalPages: number;
  activePage: number;
  onPageChange: (page: number) => void;
}

export function ElipticPagination({
  totalPages,
  activePage,
  onPageChange,
}: ElipticPaginationProps) {
  return (
    <Pagination
      style={{ display: 'flex', justifyContent: 'center' }}
      total={totalPages}
      value={activePage}
      onChange={onPageChange}
      siblings={2}
    />
  );
}

export interface SetSalaryParams {
  cardID?: stringl;
  departmentID?: number;
  salary?: number;
  childrenQuantity?: number;
  hasSpouse?: boolean;
  contributionPercentage?: number;
}

export interface CreateDepartmentParams {
  departmentName: string;
}

export interface SingleFortnightParams {
  quincenaDate: Date | null;
}
export interface MultipleFortnightsParams {
  quincenaDate: Date | null;
  n: number;
}

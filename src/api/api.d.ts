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


export interface AssignCollaboratorsParams {
  departmentID: number;
  cardIDs: number[];
}

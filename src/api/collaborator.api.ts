// API
import { api } from './api';

export const getCollaboratorName = async (cardID: number) => {
  const response = await api.get(
    `/collaborator?cardID=${cardID}`
  );
  return response.data;
};
// Axios
import { AxiosError } from 'axios';
// API
import api from './api';

interface FortnightParams {
  timestamp: Date;
}
// Insert a single fortnight into the database
const insertFortnight = async (params: FortnightParams) => {
  const { timestamp } = params;
  console.log('Inserting fortnight with timestamp: ', timestamp.toISOString());
  try {
    const response = await api.post('/fortnight', { timestamp: timestamp.toISOString() });
    return response.status;
  } catch (error) {
    console.log(error);
    if (error instanceof AxiosError && error.response) {
      throw new Error(error.response.data);
    } else if (error instanceof Error) {
      throw new Error(error.message);
    } else {
      throw new Error('Error insertando quincena.');
    }
  }
};

interface NFortnightParams {
  timestamp: Date;
  n: number;
}

const insertNFortnights = async (params: NFortnightParams) => {
  const { timestamp, n } = params;
  console.log('Inserting fortnight with timestamp: ', timestamp.toISOString());
  try {
    const response = await api.put('/fortnight', { timestamp: timestamp.toISOString(), n });
    return response.status;
  } catch (error) {
    console.log(error);
    if (error instanceof AxiosError && error.response) {
      throw new Error(error.response.data);
    } else if (error instanceof Error) {
      throw new Error(error.message);
    } else {
      throw new Error('Error insertando quincena.');
    }
  }
};

export { insertFortnight, insertNFortnights };

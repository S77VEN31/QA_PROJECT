import axios from 'axios';

const api = axios.create({
  baseURL: 'https://secure-tor-71725-08cba26ab54a.herokuapp.com',
});

export default api;

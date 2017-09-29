import axios from 'axios';
const bookingUrl = 'https://igz7ckmf26.execute-api.us-east-1.amazonaws.com';
const MileagesUrl = 'https://wuliz0a178.execute-api.us-east-1.amazonaws.com';
class IO {
	constructor() {
	}
	getMileage(id){
		return axios.get(MileagesUrl+'/Prod/airmiles/'+id);
	}
	getTickets(){
		return axios.get(bookingUrl+'/Prod/bookings');
	}
	postSubmit(req){
		return axios.post(bookingUrl+'/Prod/bookings',req);
	}
}

export const io =  new IO();

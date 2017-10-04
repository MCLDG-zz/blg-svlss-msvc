import axios from 'axios';
const bookingUrl = 'https://nm74c8rkh8.execute-api.us-east-1.amazonaws.com';
const MileagesUrl = 'https://3mk0tf6z88.execute-api.us-east-1.amazonaws.com';
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
